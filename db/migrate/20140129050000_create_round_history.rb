class CreateRoundHistory < ActiveRecord::Migration
  def change
    create_table :round_histories do |t|
    	t.integer :round_id
    	t.float :purity_percentage, :default => 1
    	t.float :btc_per_day

    	t.timestamps
    end
    add_column :pool_histories, :created_at, :datetime
    add_column :pool_histories, :updated_at, :datetime

    add_column :worker_histories, :created_at, :datetime
    add_column :worker_histories, :updated_at, :datetime

    add_index :round_histories, :round_id
  	add_index :pool_histories, :round_id
  	add_index :pool_histories, :pool_id
  	add_index :worker_histories, :round_id
  	add_index :worker_histories, :worker_id
  end
end
