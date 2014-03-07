class AddOnlineToPools < ActiveRecord::Migration
  def change

  	add_column :pools, :is_online, :boolean, :default => false
  end
end
