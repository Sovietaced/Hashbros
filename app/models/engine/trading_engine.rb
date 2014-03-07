module Engine
  # Static class for handling trading logic
	class TradingEngine

		# Periodic task run by cron job
		def self.trade_task

			''' Make sell orders on rounds without any '''
			rounds = Round.with_state(:deposits_finished)

			rounds.each do |round|
				submit_new_order(round)
			end

			''' Finalize or resubmit existing orders '''
			self.update_orders

			''' Check if pending rounds are finished '''
			self.update_rounds
		end 

		# Check if rounds are completely traded
		def self.update_rounds

			Round.with_state(:selling).each do |round|
				if round.fully_traded?
					# Update the ENUM!
					round.update_enum(:exchanged)
				elsif round.fully_cancelled?
					self.submit_new_order(round)
				end
			end
		end

		# This submits and resubmits orders for rounds
		def self.update_orders

			# Get submitted orders
			pending_orders = []

			Round.with_state(:selling).each do |round|
				pending_orders.concat(round.orders.submitted.pluck(:cryptsy_order_id))
			end

			cryptsy_order_ids = Util::CryptsyUtil.orders_by_id

			pending_orders.each do |pending_order|
				ForkHelper.fork_with_new_connection do 
					# If the order is not open, it's finished, NOTICE CAST TO STRING!!!
					if not cryptsy_order_ids.include? pending_order.cryptsy_order_id.to_s
						# If this round is finished, it must have some trades we don't know about
						self.update_trades(pending_order)

						pending_order.round.update_enum(:exchanged)

						if pending_order.complete?
							# Set the status to finished and mark the finished time with the last recorded trade time
							pending_order.update_attributes(:status => :success, :time_finished => pending_order.trades.last.created_at)
						end
					elsif pending_order.old?
						# If the order has been sitting for over an hour, lower the price
						self.resubmit_order(pending_order)
					end
				end
			end
			Process.waitall
		end

		def self.resubmit_order(order)
			# Try to cancel to cancel the order
			if self.cancel_order(order)
				# Check for partial trades
				if self.update_trades(order)
					# Open a new order
					self.submit_new_order(order.round)
				end
			end
		end

		# Attempts to cancel a sell order, returns true if succeeded
		def self.cancel_order(order)
			# Just in case of errors
			return true if order.cancelled?	
			# Call the cryptsy utility to cancel the order
			if Util::CryptsyUtil.cancel_order(order.cryptsy_order_id)
				order.update_attributes(:status => :cancelled)
				return true
			end
		end

		def self.submit_new_order(round)

			# Get the market ID
			market_id = round.pool.coin.cryptsy_market_id
			# Sell order
			order_type = "Sell"
			# 
			quantity = self.calculate_remaining_quantity(round)
			# Get a price
			price = self.calculate_price(round)

			cryptsy_order_id = Util::CryptsyUtil.create_order(market_id, order_type, quantity, price)

			if cryptsy_order_id
				# If successful we create a round row
				Order.create!(:round => round, :cryptsy_order_id => cryptsy_order_id, :price => price, :quantity => quantity, :status => :submitted)
				# Update the enum!
				round.update_enum(:selling)
			else
				NewRelic::Agent.notice_error(StandardError.new("Failed to submit a new order for round #{round.id}!"))
			end
		end

		# THis calculates the remaining order quantity, used for cases in partial orders
		def self.calculate_remaining_quantity(round)

			original_quantity = nil
			# fail safe if we have forced rounds through
			if round.auto_traded_deposit		
				# In the event that we forced a round through it may not have a confirmed amount from the deposit
				if round.auto_traded_deposit.confirmed_amount
					original_quantity = round.auto_traded_deposit.confirmed_amount
				else
					original_quantity = round.auto_traded_deposit.reported_amount
				end
			else
				original_quantity = round.total_coins_after_fees
			end
			
			return original_quantity - round.coins_traded
		end

		# Updates an order's trades, returns true if succeeded
		def self.update_trades(order)

			trade_ids = order.trades.pluck(:cryptsy_trade_id)
			market_id = order.round.pool.coin.cryptsy_market_id
			trades_json = Util::CryptsyUtil.trades(market_id)

			if trades_json
				trades_json.each do |trade_json|
					# Make sure its related to our order
					if trade_json["order_id"].to_i == order.cryptsy_order_id
						# Check if we dont know about it
						if not trade_ids.include? trade_json["tradeid"].to_i
							# Record the trade
							Trade.create!(:cryptsy_trade_id => trade_json["tradeid"],:order => order, :quantity => trade_json["quantity"], :price => order.price, :fee => trade_json["fee"], :total_btc => trade_json["total"])
						end
					end
				end
			end
			return true
		end

		# Simple for now
		def self.calculate_price(round)
			num_failed_orders = round.orders.count
			exchange_rate = round.pool.coin.exchange_rate
			one_percent_of_exchange_rate = exchange_rate / 100.0
			return exchange_rate - (num_failed_orders * one_percent_of_exchange_rate)
		end
	end
end