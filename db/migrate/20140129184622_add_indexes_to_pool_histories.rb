class AddIndexesToPoolHistories < ActiveRecord::Migration
  def change
  	add_index :pool_histories, :created_at
  	add_index :pool_histories, :pool_hash_rate_mhs
  	add_index :pool_histories, :workers_count
  end
end
