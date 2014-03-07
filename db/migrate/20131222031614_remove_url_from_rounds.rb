class RemoveUrlFromRounds < ActiveRecord::Migration
  def change
  	remove_column :rounds, :url
  end
end
