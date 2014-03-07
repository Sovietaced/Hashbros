class AddTimeStamps < ActiveRecord::Migration
  def change
  	add_column :worker_credits, :created_at, :datetime
    add_column :worker_credits, :updated_at, :datetime
    add_column :deposits, :created_at, :datetime
    add_column :deposits, :updated_at, :datetime
  end
end
