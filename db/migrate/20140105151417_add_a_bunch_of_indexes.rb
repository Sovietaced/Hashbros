class AddABunchOfIndexes < ActiveRecord::Migration
  def change
  	add_index :orders, :cryptsy_order_id
  	add_index :trades , :cryptsy_trade_id
  	add_index :users , :username
  end
end
