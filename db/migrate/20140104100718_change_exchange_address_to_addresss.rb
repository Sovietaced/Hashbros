class ChangeExchangeAddressToAddresss < ActiveRecord::Migration
  def change
  	remove_column :user_coin_settings, :exchange_address
  	add_column :user_coin_settings, :payout_address, :string
  end
end
