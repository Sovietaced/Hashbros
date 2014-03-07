class CreateProfitSwitches < ActiveRecord::Migration
  def change
    create_table :profit_switches do |t|
    	t.integer :pool_id
    	t.string :decision

    end
    add_index :profit_switches, :pool_id
  end
end
