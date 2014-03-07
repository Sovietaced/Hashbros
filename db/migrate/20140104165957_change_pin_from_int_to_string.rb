class ChangePinFromIntToString < ActiveRecord::Migration
  def change
  	change_column :users, :pin, :string
  end
end
