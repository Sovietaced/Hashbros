class CreateWorkerCredit < ActiveRecord::Migration
  def change
    create_table :worker_credits do |t|
    	t.integer :round_id
    	t.integer :worker_id 
    	t.integer :accepted_shares
    	t.integer :rejected_shares
    	t.decimal :percentage_of_work
    	t.decimal :reject_rate
    end
  end
end
