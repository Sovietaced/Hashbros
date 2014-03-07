class AddIndexToCoinHistory < ActiveRecord::Migration
  def change
  	add_index :coin_histories, :created_at
  end
end
