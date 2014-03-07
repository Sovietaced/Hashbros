class Nvm < ActiveRecord::Migration
  def change
  	remove_column :payouts, :tx_id
  	add_column :payouts, :transfer_tx_id, :string
  	add_column :payouts, :redeem_tx_id, :string
  end
end
