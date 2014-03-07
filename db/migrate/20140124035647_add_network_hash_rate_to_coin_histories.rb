class AddNetworkHashRateToCoinHistories < ActiveRecord::Migration
  def change
  	add_column :coin_histories, :network_hash_rate, :integer, :default => 0
  end
end
