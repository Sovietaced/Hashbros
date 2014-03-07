class AddColToCoins < ActiveRecord::Migration
  def change
  	add_column :coins, :cryptsy_address, :string
  	add_column :coins, :hashbros_address, :string
  	add_column :coins, :max_btc_exchange_rate, :float
  	add_column :coins, :min_btc_exchange_rate, :float
  	add_column :coins, :last_btc_exchange_rate, :float
  	remove_column :coins, :btc_exchange_rate
  	remove_column :coins, :image_url
  end
end
