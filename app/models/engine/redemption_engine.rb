module Engine
	class RedemptionEngine

		# Periodic task run by cron job
		def self.redemption_task
			self.process_redemptions
		end

		def self.process_redemptions

			# Get unprocessed redemptions and process them
			unprocessed_redemptions = Redemption.with_state(:unprocessed)

			unprocessed_redemptions.each do |unprocessed_redemption|
				self.process_redemption(unprocessed_redemption)
			end
		end

		def self.process_redemption(redemption)
			# Testing
			if not Rails.env.production?
				''' SUCESSS '''
				redemption.payouts.update_all(:is_redeemed => true)
				redemption.update_attributes(:finished => Time.now, :tx_hash => "lol", :state => :processed)
			else
				# Just in case
				return if redemption.processed?

				# As we begin this immediately update the redemption state
				redemption.update_state(:processing)

				# Blockchain operates in satoshis
				satoshis = (redemption.amount * 100000000).to_i

				coin = Coin.find_by(:symbol => "BTC")

				if coin
					# Get the payout address
					address = redemption.user.address_for(coin)

					if not address.nil? and not address.blank?

						block_chain_api_call = HTTParty.get("https://blockchain.info/merchant/#{HASHBROS_BLOCKCHAIN_ACCOUNT}/payment?password=#{HASHBROS_BLOCKCHAIN_PASSWORD}&to=#{address}&amount=#{satoshis}")

						if not block_chain_api_call.nil? and block_chain_api_call.code == 200

							# Need to verify deposit was successful
							json = ActiveSupport::JSON.decode(block_chain_api_call.body)

							if not json.nil? and json.keys.include? "tx_hash" and not json["tx_hash"].blank?

								''' SUCESSS '''
								# Update all of the redemption's payouts
								redemption.payouts.update_all(:is_redeemed => true)
								# Update this redemptions
								redemption.update_attributes(:finished => Time.now, :tx_hash => json["tx_hash"], :state => :processed, :message => "Payouts successfully redeemed.")
								# In case confirmation is needed
								return true
							else
								redemption.update_attributes(:state => :failed, :message => json["error"])
							end
						else
							redemption.update_attributes(:state => :failed, :message => "API error")
						end
					else
						redemption.update_attributes(:state => :failed, :message => "Doesn't look like your address is set.")
					end
				else
					redemption.update_attributes(:state => :failed, :message => "Couldn't find BTC coin model?")
				end
			end
		end

		def self.reprocess_redemption(redemption)
			# Testing
			return if not Rails.env.production?

			# Make sure this redemption is fully processed
			return if redemption.processed?

			# As we begin this immediately update the redemption state
			redemption.update_state(:processing)
			
			# Blockchain operates in satoshis
			satoshis = (redemption.amount * 100000000).to_i

			coin = Coin.find_by(:symbol => "BTC")

			if coin
				# Get the payout address
				address = redemption.user.address_for(coin)

				if not address.nil? and not address.blank?

					block_chain_api_call = HTTParty.get("https://blockchain.info/merchant/#{HASHBROS_BLOCKCHAIN_ACCOUNT}/payment?password=#{HASHBROS_BLOCKCHAIN_PASSWORD}&to=#{address}&amount=#{satoshis}")

					if not block_chain_api_call.nil? and block_chain_api_call.code == 200

						# Need to verify deposit was successful
						json = ActiveSupport::JSON.decode(block_chain_api_call.body)

						if not json.nil? and json.keys.include? "tx_hash" and not json["tx_hash"].blank?

							''' SUCESSS '''
							# Update all of the redemption's payouts
							redemption.payouts.update_all(:is_redeemed => true)
							# Update this redemptions
							redemption.update_attributes(:finished => Time.now, :tx_hash => json["tx_hash"], :state => :processed, :message => "Payouts successfully redeemed.")
							# In case confirmation is needed
							return true

						else
							redemption.update_attributes(:state => :failed, :message => json["error"])
						end
					else
						redemption.update_attributes(:state => :failed, :message => "API error")
					end
				else
					redemption.update_attributes(:state => :failed, :message => "Doesn't look like your address is set.")
				end
			else
				redemption.update_attributes(:state => :failed, :message => "Couldn't find BTC coin model?")
			end
		end

		def self.retry_failed_redemptions
			Redemption.with_state(:failed).each do |redemption|
				self.reprocess_redemption(redemption)
			end
		end

		def self.create_redemption(user)

			# Default BTC for now
			coin = Coin.find_by(:symbol => "BTC")

			address = user.address_for(coin)

			return {:result => :failure, :message => "You don't have your #{coin.symbol} address set!"} if address.nil? or address.blank?

			Payout.transaction do 
				# Get the ready payouts
				payouts = user.payouts.ready_locked

				total_payout = payouts.reduce(0) { |sum, payout| sum + payout.amount.to_f }

				return {:result => :failure, :message => "Payout lower than BTC transaction fee..."} if total_payout < 0.00005

				redemption = Redemption.create!(:user => user, :coin => coin, :amount => total_payout, :address => user.address_for(coin))

				if redemption
					# Assign this redemption to all these payouts
					payouts.each do |payout|
						payout.update_attributes(:redemption => redemption)
					end
					# Yay
					return {:result => :success, :message => "Redemption successfully submitted."}
				end
				return {:result => :failure, :message => "There looks to be a problem, contact support."}
			end
		end

		def self.auto_redeem	
			# TODO: Make this smarter and only query for users with at least one ready payment
			# since that could cut down on the processing

			User.enabled.each do |user|

				btc_threshold = user.btc_threshold

				# If btc threshold not set
				btc_threshold = 1.0 if btc_threshold.nil?

				if user.balance >= btc_threshold
					# Do the damn redemption
					self.create_redemption(user)
				end
			end
		end
	end
end

