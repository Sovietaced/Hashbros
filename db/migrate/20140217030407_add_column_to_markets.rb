class AddColumnToMarkets < ActiveRecord::Migration
  def change
  	add_column :markets, :exchange_market_key, :string
  end
end
