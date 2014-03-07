module Engine
	class PoolEngine

		# Periodic task run by cron job
		def self.pool_task
			self.check_pool_status
		end

		def self.check_pool_status

			Pool.active_pools.each do |pool|
				ForkHelper.fork_with_new_connection do 
					begin
						# Call the API
						api_call = HTTParty.post("http://#{pool.url}/status", {:body => {:daemon => pool.daemon, :dir => pool.dir}})

						if api_call.code == 200
							# Need to verify deposit was successful
							json = ActiveSupport::JSON.decode(api_call.body)

							if json["result"] == "success"
								pool.update_attributes(:is_online => true)
							else
								pool.update_attributes(:is_online => false)
								NewRelic::Agent.notice_error(StandardError.new("Pool #{pool.id} API seems offline!"))
							end
						else
							pool.update_attributes(:is_online => false)
							NewRelic::Agent.notice_error(StandardError.new("Pool #{pool.id} API seems offline!"))
						end

					# If we can't reach the server at all we know its down
					rescue 
						pool.update_attributes(:is_online => false)
						NewRelic::Agent.notice_error(StandardError.new("Pool #{pool.id} reported not responding!"))
					end
				end
			end
			Process.waitall
		end
	end
end
