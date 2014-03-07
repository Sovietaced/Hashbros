class AddDaemonToCoins < ActiveRecord::Migration
  def change
  	add_column :coins, :daemon, :string
  end
end
