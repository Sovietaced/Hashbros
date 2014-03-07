class AddColumnToTrades < ActiveRecord::Migration
  def change
  	add_column :trades, :cryptsy_trade_id, :integer
  end
end
