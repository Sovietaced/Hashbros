class RemoveAutoSwitchRound < ActiveRecord::Migration
  def change
  	remove_column :rounds, :is_auto_switch
  end
end
