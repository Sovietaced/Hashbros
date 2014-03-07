class Mispelledblockhash < ActiveRecord::Migration
  def change
  	remove_column :blocks, :bockhash
  	add_column :blocks, :blockhash, :string
  end
end
