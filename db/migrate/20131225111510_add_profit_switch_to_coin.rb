class AddProfitSwitchToCoin < ActiveRecord::Migration
  def change
  	add_column :coins, :is_profit_switch, :boolean
  end
end
