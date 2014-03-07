class Removedumbcolmns < ActiveRecord::Migration
  def change
  	remove_column :orders, :total_btc
  	remove_column :coins, :url
  	remove_column :blocks, :address
  end
end
