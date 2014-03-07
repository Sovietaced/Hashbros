class CreateRedemption < ActiveRecord::Migration
  def change
    create_table :redemptions do |t|
    	t.integer :user_id
    	t.boolean :is_processed
    	t.integer :coin_id
    	t.float :amount
    	t.string :address
    	t.datetime :finished
    	t.timestamps
    end

    add_index :redemptions, :user_id
    add_index :redemptions, :coin_id
  end
end
