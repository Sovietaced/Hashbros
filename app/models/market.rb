class Market < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :exchange

	# This si the coin being offered for what we're trying to sell (normally BTC/LTC)
	has_one :offer_coin, :foreign_key => 'offer_coin_id', :class_name => 'Coin'
	# This is the coin we are trying to sell
	has_one :sell_coin, :foreign_key => 'sell_coin_id', :class_name => 'Coin'

	validates_presence_of :exchange, :offer_coin, :sell_coin

	# Sexify
	rails_admin do
    	exclude_fields :offer_coin_id, :sell_coin_id
  	end
	
end
	