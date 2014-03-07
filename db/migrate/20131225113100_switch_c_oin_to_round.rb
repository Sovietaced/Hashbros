class SwitchCOinToRound < ActiveRecord::Migration
  def change
  	remove_column :rounds, :coin_id
  	add_column :rounds, :pool_id, :integer
  end
end
