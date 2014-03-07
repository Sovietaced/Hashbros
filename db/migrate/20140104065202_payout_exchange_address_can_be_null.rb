class PayoutExchangeAddressCanBeNull < ActiveRecord::Migration
  def change
  	change_column_null :payouts, :exchange_address, true
  end
end
