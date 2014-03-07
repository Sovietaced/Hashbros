class ModifyCoinHistoriesForVin < ActiveRecord::Migration
  def change
	  	remove_column :coin_histories, :min  
	  	remove_column :coin_histories, :max  
	  	remove_column :coin_histories, :last_price
	  	add_column :coin_histories, :ask, :float
	  	add_column :coin_histories, :bid, :float
	  	add_column :coin_histories, :liquidity_premium, :float
	  	add_column :coin_histories, :depth, :float
	  	add_column :coin_histories, :profitability, :float
    end
end
