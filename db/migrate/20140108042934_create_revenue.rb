class CreateRevenue < ActiveRecord::Migration
  def change
    create_table :revenues do |t|
    	t.integer :round_id
    	t.float :amount
    	t.string :address
    	t.timestamps
    end
  end
end
