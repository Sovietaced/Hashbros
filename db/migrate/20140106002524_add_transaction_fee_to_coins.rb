class AddTransactionFeeToCoins < ActiveRecord::Migration
  def change
  	add_column :coins, :transaction_fee, :decimal, {:default => 0.0005}
  end
end
