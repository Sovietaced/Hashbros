class AddTransactionIdToDeposit < ActiveRecord::Migration
  def change
  	add_column :deposits, :transaction_id, :string
  end
end
