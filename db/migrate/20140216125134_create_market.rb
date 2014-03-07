class CreateMarket < ActiveRecord::Migration
  def change
    create_table :markets do |t|
    	t.integer :exchange_id
    	t.integer :offer_coin_id
    	t.integer :sell_coin_id
    	t.float :exchange_rate, :default => 0.0
    	t.timestamps
    end
    add_index :markets, :exchange_id
    add_index :markets, :offer_coin_id
    add_index :markets, :sell_coin_id
  end
end
