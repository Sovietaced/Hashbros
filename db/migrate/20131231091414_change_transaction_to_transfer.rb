class ChangeTransactionToTransfer < ActiveRecord::Migration
  def change
  	remove_column :deposits, :transaction_id
  	add_column :deposits, :txid, :string
  end
end
