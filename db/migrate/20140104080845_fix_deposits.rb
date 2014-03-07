class FixDeposits < ActiveRecord::Migration
  def change
  	change_column_null :deposits, :round_id, true
  end
end
