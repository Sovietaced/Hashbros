module Engine
	class PayoutEngine

		def self.payout_task

			''' Find recently exchanged rounds and determine everyones payout amount '''
			exchanged_rounds = Round.with_state(:exchanged)

			exchanged_rounds.each do |round|
				self.calculate_earnings(round)
			end
		end

		# This assumed we withdraw all our money from Cryptsy so all rounds that have a balnace in cryptsy are finished
		def self.withdraw
			transferring_rounds = Round.with_state(:transferring)

			transferring_rounds.each do |round|
				round.update_enum(:complete)
			end
		end

		# For recently traded rounds, this will calculate each users earnings
		def self.calculate_earnings(round)
			round.payouts.each do |payout|
				percentage_of_work = payout.worker_credit.percentage_of_work
				amount = round.btc_traded * percentage_of_work
				payout.update_attributes(:amount => amount)
			end
			# UPDATE THE ENUM - Now all we need to do is transfer the BTC
			round.update_enum(:transferring)
		end

		# For this will calculate each users earnings based on historical exchange rates
		def self.force_calculate_earnings(round)

			coin_history = round.pool.coin.coin_histories.where(:created_at => round.start..round.end).first

			if not coin_history.nil?

				exchange_rate = coin_history.bid
				btc_traded = round.auto_traded_deposit.confirmed_amount * exchange_rate

				round.payouts.each do |payout|
					percentage_of_work = payout.worker_credit.percentage_of_work
					amount = btc_traded * percentage_of_work
					p amount
					#payout.update_attributes(:amount => amount)
				end
				# UPDATE THE ENUM - Now all we need to do is transfer the BTC
				#round.update_enum(:transferring)
			else
				Rails.logger.info "fuck"
			end
		end
	end
end
