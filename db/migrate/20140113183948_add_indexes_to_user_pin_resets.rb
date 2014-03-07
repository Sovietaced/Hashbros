class AddIndexesToUserPinResets < ActiveRecord::Migration
  def change
  	add_index :user_pin_resets, :code, :unique => true
  end
end
