module Engine# Static class for handling deposit logic
	class BlockEngine

		# Periodic task run by cron job
		def self.block_task

			self.update_blocks

		end

		def self.update_blocks

			# Iterate over rounds that are running or may have maturing blocks
			Round.with_state(:running, :over).each do |round|
				# Fork it up!
				ForkHelper.fork_with_new_connection do 

					blocks_json = self.get_round_blocks(round)

					if blocks_json
						# Iterate over the JSON array
						blocks_json.each do |block_json|
											
							block = Block.find_by_txid(block_json["txid"])

							if block
								# If the block hasn't matured write the current category/state
								block.update_attributes(:category => block_json["category"]) if block.immature?
							else
								block = Block.create!(:round => round, :category => block_json["category"], :amount => block_json["amount"], :blockhash => block_json["blockhash"], :txid => block_json["txid"], :time => Time.at(block_json["time"]).to_datetime)
							end
						end
					end

					# UPDATE ENUM
					if round.blocks_updated?
						# Rounds with no coins are complete
						if round.total_coins == 0
							round.update_enum(:complete)
						else
							# We do one last final update here because some people still mine on the old pool
							round.update_enum(:matured)
						end
					end
				end
			end
			Process.waitall
		end


		# In case we ever run into errors and need to re evaluate
		def self.force_update_blocks

			rounds = self.get_rounds_for_updating

			rounds.each do |round|

				blocks = self.get_round_blocks(round)

				if blocks
					# Iterate over the JSON array
					blocks.each do |block_json|
										
						block = Block.find_by_txid(block_json["txid"])

						if block
							# If the block hasn't matured write the current category/state
							block.update_attributes(:category => block_json["category"], :amount => block_json["amount"], :blockhash => block_json["blockhash"], :txid => block_json["txid"], :time => Time.at(block_json["time"]).to_datetime)
						else
							block = Block.create!(:round => round, :category => block_json["category"], :amount => block_json["amount"], :blockhash => block_json["blockhash"], :txid => block_json["txid"], :time => Time.at(block_json["time"]).to_datetime)
						end
					end
				end
			end
		end

		def self.get_round_blocks(round)
			# Get integer vlaues of the times
			start = round.start.to_i
			if round.end
				stop = round.end.to_i
			else
				stop = Time.now.to_i
			end

			# Get the summary from the coin node REST API
			api_call = HTTParty.post("http://#{round.pool.url}/blocks/", {:body => {:start => start, :stop => stop, :daemon => round.pool.daemon, :dir => round.pool.dir}})

			return ActiveSupport::JSON.decode(api_call.body) if api_call.code == 200

		end
	end
end