class Timestmapsforordersandtrades < ActiveRecord::Migration
  def change
  	add_column :orders, :created_at, :datetime
    add_column :orders, :updated_at, :datetime

    add_column :trades, :created_at, :datetime
    add_column :trades, :updated_at, :datetime
  end
end
