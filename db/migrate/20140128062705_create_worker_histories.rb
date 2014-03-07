class CreateWorkerHistories < ActiveRecord::Migration
  def change
    create_table :worker_histories do |t|
    	t.integer :worker_id
    	t.integer :round_id
    	t.float :hash_rate_mhs, :default => 0
    	t.integer :difficulty, :defualt => 0
    end
  end
end
