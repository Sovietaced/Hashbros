class CoinHistorySerializer < ActiveModel::Serializer
  attributes :name, :symbol, :blocks, :reward, :difficulty, :exchange_rate, :profitability_rating, :updated_at, :network_hash_rate

  def name 
  	object.coin.name
  end

  def symbol
  	object.coin.symbol
  end

  def blocks
  	object.coin.blocks
  end

  def reward 
  	object.coin.reward
  end

  def profitability_rating
    object.btc_per_day.to_f if not object.btc_per_day.nil?
  end

  def difficulty
  	object.diff.to_f if not object.diff.nil?
  end

  def updated_at
  	object.updated_at.to_i
  end

end