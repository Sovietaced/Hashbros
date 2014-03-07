class AddUsernameToWorker < ActiveRecord::Migration
  def change
  	add_column :workers, :username, :string
  end
end
