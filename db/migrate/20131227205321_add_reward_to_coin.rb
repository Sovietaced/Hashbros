class AddRewardToCoin < ActiveRecord::Migration
  def change
  	add_column :coins, :reward, :float
  end
end
