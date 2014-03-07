class AddExchangeRate < ActiveRecord::Migration
  def change
  	add_column :coins, :exchange_rate, :float
  	add_column :coin_histories, :exchange_rate, :float
  end
end
