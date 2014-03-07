class AddMarketStatsToCoins < ActiveRecord::Migration
  def change
  	add_column :coins, :btc_exchange_rate, :float
  	add_column :coins, :network_hash_rate, :float
  end
end
