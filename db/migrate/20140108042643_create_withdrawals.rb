class CreateWithdrawals < ActiveRecord::Migration
  def change
    create_table :withdrawals do |t|
    	t.integer :coin_id
    	t.float :amount
    	t.string :address
    	t.timestamps
    end
    add_index :withdrawals, :coin_id
  end
end
