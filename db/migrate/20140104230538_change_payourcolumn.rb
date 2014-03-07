class ChangePayourcolumn < ActiveRecord::Migration
  def change
  	remove_column :payouts, :exchange_address
  	add_column :payouts, :payout_address, :string
  end
end
