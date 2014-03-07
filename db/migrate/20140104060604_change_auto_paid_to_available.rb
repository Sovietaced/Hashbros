class ChangeAutoPaidToAvailable < ActiveRecord::Migration
  def change
  	remove_column :payouts, :is_autopaid
  	add_column :payouts, :is_transferred, :boolean
  end
end
