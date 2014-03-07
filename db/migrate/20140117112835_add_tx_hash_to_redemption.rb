class AddTxHashToRedemption < ActiveRecord::Migration
  def change
  	add_column :redemptions, :tx_hash, :string
  end
end
