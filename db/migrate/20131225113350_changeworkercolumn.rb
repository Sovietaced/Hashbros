class Changeworkercolumn < ActiveRecord::Migration
  def change
  	remove_column :workers, :coin_id
  	add_column :workers, :pool_id, :integer
  end
end
