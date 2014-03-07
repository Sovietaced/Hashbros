class AddCOinToWorkers < ActiveRecord::Migration
  def change
  	add_column :workers, :coin_id, :integer
  end
end
