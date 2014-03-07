module Engine	# Static class for handling deposit logic
	class DepositEngine

		# Periodic task run by cron job
		def self.deposit_task

			''' Do initial deposits on rounds that are just matured '''
			matured_rounds = Round.with_state(:matured)
			
			matured_rounds.each do |round|
				self.deposit_coins(round)
			end

			''' Retry Failed deposits '''
			#failed_deposits = Deposit.failed

			#failed_deposits.each do |deposit|
			#	self.retry_deposit(deposit)
			#end

			''' Update Cryptsy deposits '''

			self.update_cryptsy_deposits

			''' Check for completed rounds '''

			deposited_rounds = Round.with_state(:deposited)

			deposited_rounds.each do |round|
				if round.deposits_finished?
					round.update_enum(:deposits_finished)
				end
			end
		end

		def self.deposit_coins(round)

			percent_auto_trading = 0.0

			# Before doing deposits let's balance the accepted shares in case of concurrency issues
			round.audit

			coin = round.coin

			#TODO modify this for litecoin support
			payout_coin = Coin.find_by(:symbol => "BTC")

			round.worker_credits.each do |credit|
				if credit.percentage_of_work > 0.0
					if credit.user.auto_trading?(coin)
						percent_auto_trading += credit.percentage_of_work

						# If this suer is auto trading we premake a payout for them
						payout = Payout.find_by(:worker_credit => credit)
						
						if not payout
							Payout.create!(:worker_credit => credit, :coin => payout_coin)
						end
					else
						# If a user is not auto trading coins just do a direct deposit to their wallet
						self.deposit_to_user_wallet(credit)
					end
				end
			end

			# Deposit auto trading coins to cryptsy
			if self.deposit_to_cryptsy(round, percent_auto_trading) and self.deposit_to_hashbros(round)
				# UPDATE ENUM
				round.update_enum(:deposited)
			else
				# Spawn warning
			end

		end

		def self.deposit_to_user_wallet(credit)

			# If there are already deposits tied to this worker credit, don't proceed. Just to be safe.
			return if not credit.deposits.blank?
			
			# Find out how much we want to deposit
			amount = credit.round.total_coins_after_fees * credit.percentage_of_work.to_f

			address = credit.user.address_for(credit.round.pool.coin)

			if address 

				if not address.blank?
				
					# Make a post request to the coin node, instructing to dump wallet
					coin_node_api_call = HTTParty.post("http://#{credit.round.pool.url}/deposit", {:body => {:exchange_address => address, :daemon => credit.round.pool.daemon, :dir => credit.round.pool.dir, :amount => amount}})

					if coin_node_api_call.code == 200
						# Need to verify deposit was successful
						json = ActiveSupport::JSON.decode(coin_node_api_call.body)

						if json["result"] == "success"
							Deposit.create!(:round => credit.round, :worker_credit => credit, :exchange_address => address, :txid => json["txid"], :status => :finished, :reported_amount => amount)
						else
							Deposit.create!(:round => credit.round, :worker_credit => credit, :exchange_address => address, :status => :failed, :reported_amount => amount)
							NewRelic::Agent.notice_error(StandardError.new("Deposit for credit #{credit.id} failed. API returned failure"))
						end
					else
						Deposit.create!(:round => credit.round, :worker_credit => credit, :exchange_address => address, :status => :failed, :reported_amount => amount)
						NewRelic::Agent.notice_error(StandardError.new("Deposit for credit #{credit.id} failed. API returned code #{coin_node_api_call.code} "))
					end
				end
			end
		end

		def self.deposit_to_hashbros(round)

			address = round.pool.coin.hashbros_address

			if not address.blank?

				# Find out how much we want to deposit
				amount = round.total_fees

				if amount > 0.0
			
					# Make a post request to the coin node, instructing to dump wallet
					coin_node_api_call = HTTParty.post("http://#{round.pool.url}/deposit", {:body => {:exchange_address => address, :daemon => round.pool.daemon, :dir => round.pool.dir, :amount => amount}})

					if coin_node_api_call.code == 200
						# Need to verify deposit was successful
						json = ActiveSupport::JSON.decode(coin_node_api_call.body)

						if json["result"] == "success"
							Revenue.create!(:round => round, :address => address, :amount => amount, :status => :success)
						else
							Revenue.create!(:round => round, :address => address, :amount => amount, :status => :failed)
						end
					else
						Revenue.create!(:round => round, :address => address, :amount => amount, :status => :failed)
					end

					# We are satisfied since we have at least tried
					return true
				end
			end
		end

		def self.deposit_to_cryptsy(round, percentage_auto_trading)
			# Prevent duplicates just in case
			return true if not round.auto_traded_deposit.nil?
			
			# Get our cryptsy exchange address
			address = round.pool.coin.cryptsy_address

			if not address.blank?
				# Find out how much we want to deposit
				amount = round.total_coins_after_fees * percentage_auto_trading.to_f

				# Just in case
				if amount > 0.0
					# Make a post request to the coin node, instructing to dump wallet
					coin_node_api_call = HTTParty.post("http://#{round.pool.url}/deposit", {:body => {:exchange_address => address, :daemon => round.pool.daemon, :dir => round.pool.dir, :amount => amount}})

					if coin_node_api_call.code == 200
						# Need to verify deposit was successful
						json = ActiveSupport::JSON.decode(coin_node_api_call.body)

						if json["result"] == "success"
							Deposit.create!(:round => round, :exchange_address => address, :txid => json["txid"], :status => :submitted, :reported_amount => amount)
						else
							Deposit.create!(:round => round, :exchange_address => address, :status => :failed, :reported_amount => amount)
						end
					else
						Deposit.create!(:round => round, :exchange_address => address, :status => :failed, :reported_amount => amount)
					end

					# We are satisfied since we have at least tried
					return true
				end
			end
		end

		def self.retry_deposit(deposit)

			coin_node_api_call = nil
			# Deposits with rounds are auto traded by us
			if deposit.round
				coin_node_api_call = HTTParty.post("http://#{deposit.round.pool.url}/deposit", {:body => {:exchange_address => deposit.exchange_address, :daemon => deposit.round.pool.daemon, :dir => deposit.round.pool.dir, :amount => deposit.reported_amount}})
			# Deposit with worker credits are direct deposit
			elsif deposit.worker_credit
				coin_node_api_call = HTTParty.post("http://#{deposit.round.pool.url}/deposit", {:body => {:exchange_address => deposit.exchange_address, :daemon => deposit.worker_credit.pool.daemon, :dir => deposit.worker_credit.pool.dir, :amount => deposit.reported_amount}})
			end

			if coin_node_api_call.code == 200
				# Need to verify deposit was successful
				json = ActiveSupport::JSON.decode(coin_node_api_call.body)

				if json["result"] == "success"
					deposit.update_attributes(:txid => json["txid"], :status => :submitted)
				end
			end
		end

		# This checks the CRYPTSY API to check and see if they've received our deposits
		def self.update_cryptsy_deposits
			
			# Get all deposits not confirmed by cryptsy
			auto_traded_txids = Deposit.auto_traded_and_pending.pluck(:txid)

			if not auto_traded_txids.blank?
				
				deposits_json = Util::CryptsyUtil.deposits

				if deposits_json

					deposits_json.each do |deposit_json|
						
						txid = deposit_json["trxid"]

						if auto_traded_txids.include? txid
							# Since we just confirmed above we know this will always find a record
							deposit = Deposit.find_by(:txid => txid)
							time_finished = Time.at(deposit_json["timestamp"]).to_datetime
							deposit.update_attributes(:time_finished => time_finished, :status => :finished, :confirmed_amount => deposit_json["amount"])
						end
					end
				end
			end
		end
	end
end