class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
    	t.integer :round_id
    	t.string :exchange_address
    	t.datetime :time_finished
    	t.string :status
    end
  end
end
