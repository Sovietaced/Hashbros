class AddIsEnabledToWorkers < ActiveRecord::Migration
  def change
  	add_column :workers, :is_enabled, :boolean, :default => true
  end
end
