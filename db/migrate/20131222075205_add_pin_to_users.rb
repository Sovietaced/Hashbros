class AddPinToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :pin, :integer, :limit => 4
  end
end
