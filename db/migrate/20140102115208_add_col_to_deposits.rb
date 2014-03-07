class AddColToDeposits < ActiveRecord::Migration
  def change
  	add_column :deposits, :worker_credit_id, :integer
  end
end
