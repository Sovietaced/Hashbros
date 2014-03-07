class Removecolumnsfromcoins < ActiveRecord::Migration
  def change
  	remove_column :coins, :is_profit_switch
  	remove_column :coins, :is_active
  	remove_column :coins, :dir 
  	remove_column :coins, :exchange_address
  	remove_column :coins, :daemon
  end
end
