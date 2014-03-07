class PayoutAmountCanBeNull < ActiveRecord::Migration
  def change
  	change_column_null :payouts, :amount, true
  end
end
