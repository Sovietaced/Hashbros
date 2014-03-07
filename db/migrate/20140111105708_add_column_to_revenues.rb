class AddColumnToRevenues < ActiveRecord::Migration
  def change
  	add_column :revenues, :status, :string
  	remove_column :pools, :exchange_address
  end
end
