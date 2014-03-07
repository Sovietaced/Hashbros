class ModifyThresholds < ActiveRecord::Migration
  def change

  	remove_column :user_coin_settings, :auto_payout_threshold

  	add_column :users, :btc_threshold, :float
  	add_column :users, :ltc_threshold, :float

  end
end
