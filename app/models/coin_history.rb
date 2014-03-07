class CoinHistory < ActiveRecord::Base
  belongs_to :coin

  def self.average_profitability_for_day(coin, day)
  	self.where(:coin_id => coin.id, :created_at => day.beginning_of_day..day.end_of_day).average(:profitability)
  end

  def self.average_difficulty_for_day(coin, day)
    self.where(:coin_id => coin.id, :created_at => day.beginning_of_day..day.end_of_day).average(:diff)
  end

  def self.average_exchange_for_day(coin, day)
    self.where(:coin_id => coin.id, :created_at => day.beginning_of_day..day.end_of_day).average(:exchange_rate)
  end

  def self.average_network_hash_rate_for_day(coin, day)
    self.where(:coin_id => coin.id, :created_at => day.beginning_of_day..day.end_of_day).average(:network_hash_rate)
  end

  def self.average_profitabilities_for_day(coin, number_of_days)
    return self.get_averages_for_days(coin, number_of_days) do |coin, number_of_days|
      self.average_profitability_for_day(coin, number_of_days)
    end
  end

  def self.average_difficulties_for_day(coin, number_of_days)
    return self.get_averages_for_days(coin, number_of_days) do |coin, number_of_days|
      self.average_difficulty_for_day(coin, number_of_days)
    end
  end

  def self.average_exchanges_for_day(coin, number_of_days)
    return self.get_averages_for_days(coin, number_of_days) do |coin, number_of_days|
      self.average_exchange_for_day(coin, number_of_days)
    end
  end

  def self.average_network_hash_rates_for_day(coin, number_of_days)
    return self.get_averages_for_days(coin, number_of_days) do |coin, number_of_days|
      self.average_network_hash_rate_for_day(coin, number_of_days)
    end
  end

  # Method that takes in a block so that we don't have repeat this code for different averages
  def self.get_averages_for_days(coin, number_of_days, &block)
    now = DateTime.now
    averages = []
    while number_of_days > 0 do
      averages.push(block.call(coin, now - number_of_days.days))
      number_of_days -= 1
    end
    return averages
  end

  def spread
  	self.ask - self.bid
  end

  def network_hash_rate_with_magnitude(magnitude="MHs")
    mhs = self.network_hash_rate.to_f / 1000000
    if mhs == 0.0
      return "Unknown"
    elsif magnitude == "GHz"
      return ("%0.2f" % (mhs / 1000)) + " GHs"
    else
      return mhs.to_i.to_s + " MHs"
    end
  end

  def network_hash_rate_string
    mhs = self.network_hash_rate.to_f / 1000000

    if mhs == 0.0
      return "Unknown"
    elsif mhs > 1000
      return ("%0.2f" % (mhs / 1000)) + " GHs"
    end

    return mhs.to_i.to_s + " MHs "

  end
end
