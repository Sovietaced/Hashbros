class AddInternalExchangeAddressToUserCoinSettings < ActiveRecord::Migration
  def change
  	add_column :user_coin_settings, :internal_exchange_address, :string
  end
end
