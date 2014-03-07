class Derp < ActiveRecord::Migration
  def change

  	remove_column :coins, :max_btc_exchange_rate
    remove_column :coins, :min_btc_exchange_rate
    remove_column :coins, :last_btc_exchange_rate
    remove_column :coins, :volume
  end
end
