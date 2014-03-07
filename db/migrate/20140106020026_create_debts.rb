class CreateDebts < ActiveRecord::Migration
  def change
    create_table :debts do |t|
   		t.integer :user_id
   		t.float   :btc
   		t.boolean :paid
    end
    add_index :debts, :user_id
  end
end
