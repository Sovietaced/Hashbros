class CreatePools < ActiveRecord::Migration
  def change
    create_table :pools do |t|
    	t.integer  :coin_id
	    t.string   :url
	    t.string   :exchange_address
	    t.string   :daemon
	    t.boolean  :is_active
	    t.string   :dir
	    t.boolean  :is_profit_switch

	    t.timestamps
    end
  end
end
