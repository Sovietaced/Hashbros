class AddAmountsToDeposits < ActiveRecord::Migration
  def change
  	add_column :deposits, :reported_amount, :float
  	add_column :deposits, :confirmed_amount, :float
  end
end
