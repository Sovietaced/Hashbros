class AddCOlumnToPools < ActiveRecord::Migration
  def change
  	add_column :pools, :calculated_hash_rate_mhs, :float
  end
end
