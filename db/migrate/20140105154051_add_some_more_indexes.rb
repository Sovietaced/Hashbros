class AddSomeMoreIndexes < ActiveRecord::Migration
  def change
  	# Add an index on these 2 fields together to hopefully speed up 2 methods:
  	# Pool::standalone_and_active and Pool::profit_switching_and_active
  	add_index :pools, [:is_profit_switch, :is_active]
  	# Since we query on the name field
  	add_index :coins, :name

  end
end
