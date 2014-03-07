class AddDirToCoins < ActiveRecord::Migration
  def change
  	add_column :coins, :dir, :string
  end
end
