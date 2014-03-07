class UserCoinSetting < ActiveRecord::Base
	default_scope { order(:id)}
	
	belongs_to :user
	belongs_to :coin

	# Determines if the user is auto trading to BTC
	def auto_trading?
		if not payout_address.nil?
			if not payout_address.blank?
				return is_auto_trading?
			end
		end
		# Default case is always true
		return true
	end

	def address_valid?(address)

		pool = coin.pools.first

		if pool
			begin
	 			# Call the coin node api
				coin_node_api_call = HTTParty.post("http://#{pool.url}/validate_address", {:body => {:daemon => pool.daemon, :dir => pool.dir, :address => address}})
				if coin_node_api_call.code == 200
					response = ActiveSupport::JSON.decode(coin_node_api_call.body) 

					if response["result"] == "success"
						return true
					else
						return false
					end
				end
			rescue 
				return true
			end
		end
		# Default case return true
		return true
	end
end

