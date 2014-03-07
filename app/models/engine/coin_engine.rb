module Engine
	# Static class for handling deposit logic
	class CoinEngine

		# Periodic task run by cron job
		def self.coin_task
			self.update_coins
		end

		def self.get_coin_node_data(pool)
			begin
     			# Call the coin node api
				coin_node_api_call = HTTParty.post("http://#{pool.url}/coins", {:body => {:daemon => pool.daemon, :dir => pool.dir}})
				return ActiveSupport::JSON.decode(coin_node_api_call.body) if coin_node_api_call.code == 200
			rescue Timeout::Error
  				Rails.logger.info "#{pool.coin.name down}"
  			rescue 
  				Rails.logger.info "#{pool.coin.name} pool error"
  			end
		end

		def self.get_cryptsy_data(pool)
			Util::CryptsyUtil.market_orders(pool.coin.cryptsy_market_id)
		end

		def self.get_exchange_rates
			Util::CryptsyUtil.get_exchange_rates
		end

		def self.update_coins

			exchange_rates = self.get_exchange_rates

			if exchange_rates
				Pool.active_and_online_pools.each do |pool|
					ForkHelper.fork_with_new_connection do 
						# Get the exchange rate for this coin
						exchange_info = exchange_rates.detect{|market| market["marketid"].to_i == pool.coin.cryptsy_market_id}
						
						if exchange_info
							# Only update the pool if we have the correct exchange rate
							self.update_coin(pool, exchange_info["last_trade"].to_f)
			  			end
			  		end
		  		end
		  		Process.waitall
		  	end
		end

		def self.update_coin(pool, exchange_rate)

			coin = pool.coin
			puts "Updating coin " + coin.symbol
				
			coin_json = self.get_coin_node_data(pool)

			if coin_json
				coin.update_attributes(:exchange_rate => exchange_rate, :difficulty => coin_json["difficulty"], :network_hash_rate => coin_json["network_hash_rate"], :blocks => coin_json["blocks"])
			end

			# Reload the model after the changes we've made
			coin = coin.reload

			market_json = self.get_cryptsy_data(pool)

			if market_json
				sell_orders = market_json["sellorders"]
				buy_orders = market_json["buyorders"]
				
				if not sell_orders.blank? and not buy_orders.blank?
					# Get the most recent ask and bid
					ask = sell_orders[0]["sellprice"].to_f
					bid = buy_orders[0]["buyprice"].to_f
					liquidity = ask - bid
					depth = self.calculate_depth(buy_orders, sell_orders)
					# This is just raw simple profitability based on btc per day
					btc_per_day = self.calculate_btc_per_day(pool, exchange_rate)
					# This is our proprietary profitability rating
					profitability = btc_per_day * depth

					if coin.difficulty
						CoinHistory.create!(:coin => coin, :exchange_rate => coin.exchange_rate, :diff => coin.difficulty, :network_hash_rate => coin.network_hash_rate, :blocks => coin.blocks, :ask => ask, :bid => bid, :liquidity_premium => liquidity, :depth => depth, :profitability => profitability, :btc_per_day => btc_per_day)
					end
				end
			end
		end

		''' Functions for calculations '''
		def self.calculate_btc_per_day(pool, exchange_rate)

			coin = pool.coin

		 	time_to_find_block_with_one_megahash = coin.difficulty.to_f * 2**32 / 1000000
		 	seconds_in_a_day = 86400
		 	blocks_in_a_day = seconds_in_a_day / time_to_find_block_with_one_megahash
		 	coins_in_a_day = blocks_in_a_day * coin.reward
		 	btc_per_day = coins_in_a_day * exchange_rate
		 	# Depth adjusted
		 	return btc_per_day 
		end

		def self.calculate_depth(buy_orders, sell_orders)
			lowest_sell = sell_orders[0]["sellprice"].to_f
			highest_buy = buy_orders[0]["buyprice"].to_f

			buy_pq, sell_pq = 0.0, 0.0

			buy_orders.each do |buy_order|
				buy_pq += buy_order["total"].to_f if buy_order["buyprice"].to_f >= 0.975 * lowest_sell	
			end

			sell_orders.each do |sell_order|
				sell_pq += sell_order["total"].to_f if sell_order["sellprice"].to_f <= 1.025 * highest_buy
			end

			return 0 if sell_pq == 0 or buy_pq ==0
			return buy_pq / (buy_pq + sell_pq)
		end
	end
end
