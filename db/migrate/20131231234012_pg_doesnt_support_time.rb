class PgDoesntSupportTime < ActiveRecord::Migration
  def change
  	remove_column :blocks, :time 
  	add_column :blocks, :time, :datetime
  end
end
