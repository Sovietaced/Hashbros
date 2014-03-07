class AddcolumnToPayouts < ActiveRecord::Migration
  def change
  	add_column :payouts, :status, :string
  end
end
