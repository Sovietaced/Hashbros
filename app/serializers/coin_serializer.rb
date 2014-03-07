class CoinSerializer < ActiveModel::Serializer
  attributes :name, :symbol, :exchange_rate, :difficulty, :reward, :blocks, :reward, :updated_at, :network_hash_rate

end