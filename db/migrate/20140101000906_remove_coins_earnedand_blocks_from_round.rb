class RemoveCoinsEarnedandBlocksFromRound < ActiveRecord::Migration
  def change
  	remove_column :rounds, :coins_earned
  	remove_column :rounds, :blocks
  	remove_column :rounds, :btc_earned
  end
end
