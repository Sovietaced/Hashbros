class AddtimestampsToBlocks < ActiveRecord::Migration
  def change
  	add_column :blocks, :created_at, :datetime
    add_column :blocks, :updated_at, :datetime

  end
end
