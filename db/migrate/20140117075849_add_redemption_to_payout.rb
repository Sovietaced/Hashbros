class AddRedemptionToPayout < ActiveRecord::Migration
  def change
  	remove_column :payouts, :payout_address
  	remove_column :payouts, :redeem_tx_id
  	remove_column :payouts, :transfer_tx_id
  	remove_column :payouts, :is_transferred

  	add_column :payouts, :redemption_id, :integer
  	add_column :payouts, :coin_id, :integer

  	add_index :payouts, :redemption_id
  	add_index :payouts, :coin_id

  end
end
