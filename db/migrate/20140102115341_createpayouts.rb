class Createpayouts < ActiveRecord::Migration
  def change
  	create_table :payouts do |t|
    	t.integer  :worker_credit_id
	    t.float	   :fees
	    t.string   :exchange_address
	    t.boolean  :is_redeemed
	    t.boolean  :is_autopaid

	    t.timestamps
    end

    add_index :payouts, :worker_credit_id, :unique => true
  end
end
