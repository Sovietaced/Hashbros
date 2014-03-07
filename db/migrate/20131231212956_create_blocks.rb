class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
        t.integer :round_id
    	t.string :address
    	t.string :category
    	t.float :amount
    	t.string :bockhash
    	t.time :time
    	t.string :txid
    end
  end
end
