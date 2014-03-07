class AddSymbolToCoin < ActiveRecord::Migration
  def change
  	add_column :coins, :symbol, :string
  end
end
