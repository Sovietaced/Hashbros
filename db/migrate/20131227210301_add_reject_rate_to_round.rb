class AddRejectRateToRound < ActiveRecord::Migration
  def change
  	add_column :rounds, :reject_rate, :float
  end
end
