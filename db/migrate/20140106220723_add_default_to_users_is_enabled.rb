class AddDefaultToUsersIsEnabled < ActiveRecord::Migration
  def change
  	change_column_default :users, :is_enabled, false
  end
end
