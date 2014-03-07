class AddcolToTrades < ActiveRecord::Migration
  def change
  	add_column :trades, :quantity, :float
  	add_column :trades, :price, :float
  end
end
