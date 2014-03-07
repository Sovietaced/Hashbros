class AddColumnToPayouts < ActiveRecord::Migration
  def change
  	add_column :payouts, :amount, :float
  end
end
