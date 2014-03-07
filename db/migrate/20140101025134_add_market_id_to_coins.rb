class AddMarketIdToCoins < ActiveRecord::Migration
  def change
  	add_column :coins, :cryptsy_market_id, :integer
  end
end
