class AddAutoPayoutThresholdToUserCoinSettings < ActiveRecord::Migration
  def change
    add_column :user_coin_settings, :auto_payout_threshold, :float
  end
end
