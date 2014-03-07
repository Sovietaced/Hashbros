class AddBlocksToTables < ActiveRecord::Migration
  def change
  	add_column :coins, :blocks, :integer
  	add_column :coin_histories, :blocks, :integer
  end
end
