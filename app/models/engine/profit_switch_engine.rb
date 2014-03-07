 module Engine
	 # Static class for handling engine logic
	class ProfitSwitchEngine

		def self.current_coin
			self.current_pool.coin
		end

		def self.current_pool
			ProfitSwitch.last.pool if !ProfitSwitch.last.nil?
		end

		def self.current_round
			self.current_pool.rounds.last
		end

		# This will be a periodic task
		def self.profit_switch_task

			# Make sure socat is running
			self.check_routing

			# Check if a more profitable pool exists
			pool = self.determine_most_profitable_pool
			if pool
				self.profit_switch(pool) if self.skip_block?
			end
		end

		def self.profit_switch(new_pool)

			old_pool = self.current_pool
			old_round = self.current_round

			# Point socat to the new coin
			self.reset_routing(new_pool)

			# Cut the round
			self.start_new_round(old_pool,new_pool)

			ProfitSwitch.create!(:pool => new_pool, :decision => "Profitability Rating")

		end

		def self.check_routing
			# Check if socat is running
			if `ps aux | grep soca[t]` == ""
				self.reset_routing(self.current_pool)
			end
		end

		# Basically this will always work because linux. If it doesnt this is bad
		def self.reset_routing(pool)
	    	 # Tell SOCAT to switch to new coin, we're gonna just abstract this away and assume it works
		    %x(killall socat > log/switch.log 2>&1)
		    %x(socat tcp-listen:3333,reuseaddr,fork, tcp-connect:#{pool.url}:3333 > log/switch.log 2>&1 &)

		    Relay.all.each do |relay|
				# Get the summary from the coin node REST API
				api_call = HTTParty.post("http://#{relay.url}/set/", {:body => {:url => pool.url}})

				if api_call.code == 200
					if ActiveSupport::JSON.decode(api_call.body)["result"] == "success"
						relay.update_attributes(:status => :up)
					else
						relay.update_attributes(:status => :down)
					end
				end
			end

		end

		def self.skip_block?
			pool = self.current_pool

			current_round = self.current_round

			return true if (Time.now - current_round.created_at) > 15.minutes

			# current_block = current_round.blocks.last

			# if current_block
			# 	# Skip the block because we are less than halfway through
			# 	return true if (Time.now - current_block.created_at) < (time_to_find_block / 2)
			# 	# Skip the block block if we're more than twice over
			# 	return true if (Time.now - current_block.created_at) > (time_to_find_block * 2)
			# else
			# 	# Skip the block because we are less than halfway through
			# 	return true if (Time.now - current_round.created_at) <	 (time_to_find_block / 2)
			# 	# Skip the block block if we're more than twice over
			# 	return true if (Time.now - current_round.created_at) > (time_to_find_block * 2)
			#end

		end

		def self.calculate_block_time(pool)
			return pool.coin.difficulty.to_f * 2**32 / (self.current_pool.calculated_hash_rate_mhs.to_f * 1000000.0)
		end

		def self.test

			Relay.all.each do |relay|
				# Get the summary from the coin node REST API
				api_call = HTTParty.post("http://#{relay.url}/set/", {:body => {:url => self.current_pool.url}})
			end
		end

		# Starts a new round
		def self.start_new_round(old_pool, new_pool=nil)

			if not old_pool.rounds.blank?
				old_round = old_pool.rounds.last
				old_round.end = Time.now
				old_round.update_enum(:over)
				old_round.save!
			end

			 if new_pool.nil?
			 	new_round = Round.create!(:start => Time.now, :pool => old_pool)
			 else
			 	new_round = Round.create!(:start => Time.now, :pool => new_pool)
			 end
		end

		def self.get_round_stats(round)

			# Get integer vlaues of the times
			start = round.start.to_i
			if round.end
				stop = round.end.to_i
			else
				stop = Time.now.to_i
			end

			# Get the summary from the coin node REST API
			api_call = HTTParty.post("http://#{round.pool.url}/summary/", {:body => {:start => start, :stop => stop, :daemon => round.pool.daemon, :dir => round.pool.dir}})
			# Return nil of the request was no bueno
			return ActiveSupport::JSON.decode(api_call.body) if api_call.code == 200
		end

		# Update rounds with shares info
		def self.update_rounds
			self.get_pools_for_polling.each do |pool|
				ForkHelper.fork_with_new_connection do 
					if not pool.rounds.blank?

						round = pool.rounds.last

						# We only care about unfinished pools
						if not round.over?
							# Get the stats of the last and most up to date round
							self.update_round(round)
						end
					end
				end
			end
			Process.waitall
		end

		def self.update_round(round)

			# Get the stats of the last and most up to date round
			stats = self.get_round_stats(round)

			if stats
				round.update_attributes(:shares => stats["total_shares"], :accepted => stats["accepted_shares"], :rejected => stats["rejected_shares"], :reject_rate => stats["reject_rate"])

				stats["work"].keys.each do |username|

					work = stats["work"][username]
					worker = Worker.find_by_username(username)

					if worker
						credit = WorkerCredit.where(:round => round, :worker => worker).first

						if credit
							credit.update_attributes(:accepted_shares => work["accepted_shares"], :rejected_shares => work["rejected_shares"], :reject_rate => work["reject_rate"])
						else
							WorkerCredit.create!(:worker => worker, :round => round, :accepted_shares => work["accepted_shares"], :rejected_shares => work["rejected_shares"], :reject_rate => work["reject_rate"])
						end
					end
				end
			else
				# Spawn email error
			end
		end

		# Polls all the stand coin nodes for worker stats and updates them appropriately
		def self.update_worker_stats

			pools = [self.current_pool]
			pools.each do |pool|
				ForkHelper.fork_with_new_connection do 
					# Get the worker stats from the coin node REST API
					puts "making api call " + Time.now.to_s
					api_call = HTTParty.get("http://#{pool.url}/worker_stats")
					puts "finished api call " + Time.now.to_s
					if api_call.code == 200

						json = ActiveSupport::JSON.decode(api_call.body)
						pool_hash_rate_mhs = 0
						# Iterate over the JSON array
						json.each do |json_obj|

							worker = Worker.find_by_username(json_obj["username"])

							# If the workout is in our DB update the stats.
							if worker
								hash_rate_mhs = json_obj["hashrate"]
								diff = json_obj["difficulty"]
								worker.update_attributes(:hash_rate_mhs => hash_rate_mhs, :difficulty => diff)

								# Create a worker history for this worker
								WorkerHistory.create!(:worker => worker, :round => pool.rounds.last, :hash_rate_mhs => hash_rate_mhs, :difficulty => diff)

								# Add this worker's hash rate to the pool
								pool_hash_rate_mhs += hash_rate_mhs
							end
						end

						pool.update_attributes(:calculated_hash_rate_mhs => pool_hash_rate_mhs)

						# Create a 
						PoolHistory.create!(:pool => pool, :round => pool.rounds.last, :pool_hash_rate_mhs => pool_hash_rate_mhs, :workers_count => json.count)
					else
						# Spawn email or exception
					end
				end
			end
			# Wait for all our processes to finish
			Process.waitall
		end

		def self.fix
			Round.all.find_each do |round|
				if round.worker_credits.blank?
					Rails.logger.info round.id
					self.update_round(round)
				end
			end
		end

		def self.get_pools_for_polling

			pools = Pool.standalone_and_active
	        current_pool = self.current_pool

	        if current_pool
		        pools.push(current_pool) if not pools.include? current_pool
		    end

		    return pools
		end

		def self.determine_most_profitable_pool

			pools = Pool.profit_switching_and_active

			profitability_ratings = {}

			pools.each do |pool|
				# We only care about pools that have blocks less than an hour in length
				if self.calculate_block_time(pool) < 6.minutes.to_i
					rating = pool.coin.profitability

					# Account for purity
					rating = rating * pool.average_purity
					
					profitability_ratings[pool.id] = rating
				end
			end

			sorted_profitability_ratings = Hash[profitability_ratings.sort_by(&:last).reverse!]

			current_round = Engine::ProfitSwitchEngine.current_round
			# Create each of the profitability_analytics rows
			sorted_profitability_ratings.each_with_index do |(key, value), index|
				ProfitabilityAnalytics.create!(:vwap => value, :rating => index, :pool_id => key, :round_id => current_round.id)
			end

			pool = Pool.find_by_id(sorted_profitability_ratings.keys.first)
			return pool if pool != self.current_pool

		end
	end
end
