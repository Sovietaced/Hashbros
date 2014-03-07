class AddActiveToCoin < ActiveRecord::Migration
  def change
  	add_column :coins, :is_active, :boolean
  end
end
