class AddMessageToRedemptions < ActiveRecord::Migration
  def change
  	add_column :redemptions, :message, :string
  end
end
