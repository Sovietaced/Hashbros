class CryptsyTradeIdCanBeNull < ActiveRecord::Migration
  def change
  	change_column_null :trades, :cryptsy_trade_id, true
  end
end
