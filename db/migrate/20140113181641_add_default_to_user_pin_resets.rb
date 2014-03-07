class AddDefaultToUserPinResets < ActiveRecord::Migration
  def change
  	change_column_default :user_pin_resets, :used, false
  end
end
