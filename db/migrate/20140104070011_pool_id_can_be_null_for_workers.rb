class PoolIdCanBeNullForWorkers < ActiveRecord::Migration
  def change
  	change_column_null :workers, :pool_id, true
  end
end
