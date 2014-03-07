class CreateUserLeaderboards < ActiveRecord::Migration
  def change
    create_table :user_leaderboards do |t|
    	t.integer :user_id
    	t.float :earnings_btc
    	t.integer :shares

    	t.timestamps
    end

    add_index :user_leaderboards, :user_id, :unique => true
    
  end
end
