class AddTypeToPools < ActiveRecord::Migration
  def change
  	add_column :pools, :type_of, :integer, :default => 0
  	add_column :pools, :state, :integer, :default => 0
  end
end
