class AddAddressToCoin < ActiveRecord::Migration
  def change
  	add_column :coins, :exchange_address, :string
  end
end
