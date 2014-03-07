class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.integer :user_id
      t.float :hash_rate_mhs
      t.boolean :is_active
      t.integer :difficulty
      t.float :reject_rate

      t.timestamps
    end

    add_index :workers, :user_id
  end
end
