class Coin < ActiveRecord::Base
	default_scope { order(:name)}

	has_many :pools, :dependent => :destroy
	has_many :coin_histories, :dependent => :destroy

	validates_presence_of :reward, :cryptsy_address, :cryptsy_market_id, :symbol, :hashbros_address

	# Rails admins throws a bitch fit so I have to resctive has many through relationships
	rails_admin do
    exclude_fields :pools, :coin_histories
  end

  # Helper for getting the bitcoin coin
  def self.btc
    Coin.find_by_symbol("BTC")
  end

  # Helper for getting all coins besides bitcoin
  def self.except_btc
    Coin.all.delete_if{|coin| coin.symbol == "BTC"}
  end

	def profitability
    # Gets profitability rating over the last 30 mins
    last_mins = self.coin_histories.where(:created_at => (Time.now - 8.minutes)..Time.now)
	  return last_mins.collect(&:btc_per_day).sum.to_f / last_mins.count
	end

	def spread
		history = self.coin_histories.last
  		history.ask - history.bid
	end

	def ask
		self.coin_histories.last.ask
	end

	def bid
		self.coin_histories.last.bid
	end

	def image_url
		"coins/" + self.name + ".png"
	end

  def self.get_average_profitabilities(number_of_days=7)
    coin_average_profitabilities = {}
    Coin.all.each do |coin|
      coin_average_profitabilities[coin.id] = CoinHistory.average_profitabilities_for_day(coin, number_of_days)
    end
    return coin_average_profitabilities
  end

  def self.get_average_difficulties(number_of_days=7)
    coin_average_difficulties = {}
    Coin.all.each do |coin|
      coin_average_difficulties[coin.id] = CoinHistory.average_difficulties_for_day(coin, number_of_days)
    end
    return coin_average_difficulties
  end

  def self.get_average_exchanges(number_of_days=7)
    coin_average_exchanges = {}
    Coin.all.each do |coin|
      coin_average_exchanges[coin.id] = CoinHistory.average_exchanges_for_day(coin, number_of_days)
    end
    return coin_average_exchanges
  end

  def self.get_average_network_hash_rates(number_of_days=7)
    coin_average_network_hash_rates = {}
    Coin.all.each do |coin|
      coin_average_network_hash_rates[coin.id] = CoinHistory.average_network_hash_rates_for_day(coin, number_of_days)
    end
    return coin_average_network_hash_rates
  end

  def get_average_profitabilities(number_of_days=7)
      CoinHistory.average_profitabilities_for_day(self, number_of_days)
  end

  def get_average_difficulties(number_of_days=7)
    CoinHistory.average_difficulties_for_day(self, number_of_days)
  end

  def get_average_exchanges(number_of_days=7)
      CoinHistory.average_exchanges_for_day(self, number_of_days)
  end

  def get_average_network_hash_rates(number_of_days=7)
     CoinHistory.average_network_hash_rates_for_day(self, number_of_days)
  end

  def self.get_list_of_coins
    return Coin.all().map(&:name).to_sentence
  end

  def address_valid?(address)

    pool = self.pools.first

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
