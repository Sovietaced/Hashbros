class AddEvenMoreIndexesYay < ActiveRecord::Migration
  def change
  	# All of these are to help mitigate slow DB queries that use "where"
  	add_index :rounds, :start
  	add_index :coins, :symbol
  	add_index :deposits, :time_finished
  	add_index :deposits, :status
  	add_index :deposits, :txid
  	add_index :worker_credits, [:round_id, :worker_id]
  	add_index :orders, :status
  	add_index :payouts, :amount
  	add_index :rounds, :end
  	add_index :user_coin_settings, [:user_id, :coin_id]
  end
end
