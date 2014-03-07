class CreatePoolHistory < ActiveRecord::Migration
  def change
    create_table :pool_histories do |t|
    	t.integer :pool_id
    	t.integer :round_id
    	t.float :pool_hash_rate_mhs, :default => 0
    	t.integer :workers_count, :default => 0
    end
  end
end
