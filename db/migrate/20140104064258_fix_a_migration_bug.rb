class FixAMigrationBug < ActiveRecord::Migration
  def change
  	change_column_null :deposits, :worker_credit_id, true
  end
end
