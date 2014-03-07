class CreateUsercoinSettings < ActiveRecord::Migration
  def change
    create_table :user_coin_settings do |t|
    	t.integer :user_id
    	t.integer :coin_id
    	t.boolean :is_auto_trading

    	t.timestamps
    end

    add_index :user_coin_settings, :user_id
    add_index :user_coin_settings, :coin_id
  end
end
