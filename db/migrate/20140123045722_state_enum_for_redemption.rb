class StateEnumForRedemption < ActiveRecord::Migration
  def change
  	remove_column :redemptions, :is_processed
  	add_column :redemptions, :state, :integer, :default => 0

  	add_index :redemptions, :state
  end
end
