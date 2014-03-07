class Bigints < ActiveRecord::Migration
  def change
  	remove_column :coins, :network_hash_rate
  	remove_column :coin_histories, :network_hash_rate
  	add_column :coins, :network_hash_rate, :integer, :limit => 8
  	add_column :coin_histories, :network_hash_rate, :integer, :limit => 8
  end
end
