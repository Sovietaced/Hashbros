class RemoveRejectRate < ActiveRecord::Migration
  def change
  	remove_column :workers, :reject_rate
  end
end
