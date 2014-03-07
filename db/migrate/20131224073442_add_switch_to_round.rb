class AddSwitchToRound < ActiveRecord::Migration
  def change
  	add_column :rounds, :is_auto_switch, :boolean
  end
end
