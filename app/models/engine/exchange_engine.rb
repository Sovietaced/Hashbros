module Engine
	# Static class for handling deposit logic
	class ExchangeEngine < Adapters::ExchangeInterface

		# Periodic task run by cron job
		def self.task
			# nothing
		end

		# This makes a withdrawal from our exchanges
		def self.withdraw

			coin = Coin.find_by_symbol("BTC")
			balance = Util::CryptsyUtil.get_balance("BTC")

			result = nil
			if not balance.nil?
				result = Util::CryptsyUtil.make_withdrawal(coin.hashbros_address, balance)
			else
				NewRelic::Agent.notice_error(StandardError.new("Failed to get BTC balance from Cryptsy"))
			end

			# Life is good
			if not result.nil?
				# Create a record of this withdrawal
				Withdrawal.create!(:amount => balance, :coin => coin)
				enum_int = Round.state.find_value(:complete).value 
				# Mark all rounds awaiting withdrawal as completed
				Round.with_state(:transferring).update_all(:state => enum_int)	
			else
				NewRelic::Agent.notice_error(StandardError.new("Failed to withdraw from Cryptsy"))
			end
		end
	end
end
