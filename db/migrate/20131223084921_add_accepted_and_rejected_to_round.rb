class AddAcceptedAndRejectedToRound < ActiveRecord::Migration
  def change
  	add_column :rounds, :accepted, :integer
  	add_column :rounds, :rejected, :integer
  end
end
