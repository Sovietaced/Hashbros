class AddTxIdToPayout < ActiveRecord::Migration
  def change
  	add_column :payouts, :tx_id, :string
  end
end
