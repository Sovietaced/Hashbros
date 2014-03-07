class AddCOlumnToDeposits < ActiveRecord::Migration
  def change
  	add_column :deposits, :fees, :float

  	add_index :blocks, :round_id

  	add_index :deposits, :round_id
  	add_index :deposits, :worker_credit_id

  	add_index :orders, :round_id

  	add_index :pools, :coin_id

  	add_index :rounds, :pool_id

  	add_index :trades, :order_id

  	add_index :worker_credits, :round_id
  	add_index :worker_credits, :worker_id
  end
end
