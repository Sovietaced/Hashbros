class AddVolumeToCoin < ActiveRecord::Migration
  def change
  	add_column :coins, :volume, :float
  end
end
