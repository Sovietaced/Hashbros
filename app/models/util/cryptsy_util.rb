module Util

	# This is a wrapper around the existing cryptsy api
	class CryptsyUtil
		
		@@cryptsy = Cryptsy::API::Client.new('<Cryptsy key>', '<Cryptsy key>')

		def self.deposits

			response = nil

			begin
				response = @@cryptsy.mytransactions
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace}"))
			end 

			return self.verify(response)
		end

		# NOTE : Cryptsy only returns open orders
		def self.orders
			response = nil

			begin
				response = @@cryptsy.allmyorders
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace}"))
			end 

			return self.verify(response)
		end

		def self.get_info
			response = nil

			begin
				response = @@cryptsy.getinfo
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace}"))
			end 

			return self.verify(response)
		end

		def self.get_balance(symbol)
			balances_json = self.get_info

			# Just to be super careful we have a valid value before casting to float
			if not balances_json.nil? and balances_json.has_key?("balances_available") and balances_json["balances_available"].has_key?(symbol)
				return balances_json["balances_available"][symbol].to_f
			end
		end

		def self.make_withdrawal(symbol, amount)
			response = nil

			begin
				response = @@cryptsy.makewithdrawal(symbol, amount)
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace}"))
			end 

			return self.verify(response)
		end

		def self.get_exchange_rates
			response = nil

			begin
				response = @@cryptsy.getmarkets
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace}"))
			end 

			return self.verify(response)
		end

		def self.orders_by_id

			orders = self.orders
			ids = []

			if orders
				orders.each do |order_json|
					ids.push(order_json["orderid"])
				end
			end

			return ids
		end

		def self.trades(market_id)

			response = nil

			begin
				if market_id
					response = @@cryptsy.mytrades(market_id, nil)
				else
					response = @@cryptsy.allmytrades
				end
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace} "))
			end 

			return self.verify(response)
		end

		def self.create_order(market_id, order_type, quantity, price)
			response = nil

			begin
				response = @@cryptsy.createorder(market_id, order_type, quantity, price)
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace}"))
			end 

			return self.verify(response)
		end

		def self.cancel_order(order_id)
			response = nil

			begin
				response = @@cryptsy.cancelorder(order_id)
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace}"))
			end 

			# Make sure the request was successful
			# Also if there is a glitch and it is removed it will appear as not belong to us
			if not response.nil? and (response["success"] == "1" or response["error"].include? "does not appear to belong to you")
				return true	
			end
		end

		def self.market_orders(market_id)
			response = nil

			begin
				response = @@cryptsy.marketorders(market_id)
			rescue => e
				NewRelic::Agent.notice_error(StandardError.new("Cryptsy API failure. Backtrace : #{e.backtrace}"))
			end 

			return self.verify(response)
		end

		# Checks if the response is not nil
		# Then returns the response JSON if api call is a success (per Cryptsy reply)
		def self.verify(response)
			if not response.nil? and response["success"] == "1"
				return response["return"]	
			end
		end

	end
end
