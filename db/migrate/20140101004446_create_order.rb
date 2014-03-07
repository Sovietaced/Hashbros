class CreateOrder < ActiveRecord::Migration
  def change
    create_table :orders do |t|
        t.integer :cryptsy_order_id
    	t.integer :round_id
    	t.float :price
    	t.float :quantity
    	t.float :total_btc
    	t.string :status
    	t.datetime :time_finished
    end
  end
end
