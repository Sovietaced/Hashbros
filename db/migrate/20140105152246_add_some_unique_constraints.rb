class AddSomeUniqueConstraints < ActiveRecord::Migration
  def change
  	# Unique worker names
  	add_index :workers, :username, :unique => true
  end
end
