class RenameSomeShit < ActiveRecord::Migration
  def change
  	remove_column :coin_histories, :simple_profitability
  	add_column :coin_histories, :btc_per_day, :float
  end
end
