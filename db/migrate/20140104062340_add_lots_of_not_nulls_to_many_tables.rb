class AddLotsOfNotNullsToManyTables < ActiveRecord::Migration
  def change
  	change_column_null :blocks, :round_id, false
  	change_column_null :deposits, :round_id, false
  	change_column_null :deposits, :exchange_address, false
  	change_column_null :orders, :cryptsy_order_id, false
  	change_column_null :orders, :round_id, false
  	change_column_null :orders, :price, false
  	change_column_null :orders, :quantity, false
  	change_column_null :payouts, :worker_credit_id, false
  	change_column_null :pools, :coin_id, false
  	change_column_null :rounds, :pool_id, false
  	change_column_null :trades, :order_id, false
  	change_column_null :user_coin_settings, :user_id, false
  	change_column_null :user_coin_settings, :coin_id, false
  	change_column_null :users, :pin, false, '1234'
  	change_column_null :worker_credits, :round_id, false
  	change_column_null :worker_credits, :worker_id, false
  	change_column_null :workers, :user_id, false
  	change_column_null :workers, :username, false
  end
end
