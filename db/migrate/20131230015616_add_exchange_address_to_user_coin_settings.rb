class AddExchangeAddressToUserCoinSettings < ActiveRecord::Migration
  def change
  	add_column :user_coin_settings, :exchange_address, :string
  end
end
