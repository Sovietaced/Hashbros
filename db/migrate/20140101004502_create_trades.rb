class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
    	t.integer :order_id
    	t.float :fee
    	t.float :total_btc
    end
  end
end
