class AddNotificaitonsToWorkers < ActiveRecord::Migration
  def change
  	add_column :workers, :send_notifications, :boolean
  	add_column :workers, :notification_interval, :string
  end
end
