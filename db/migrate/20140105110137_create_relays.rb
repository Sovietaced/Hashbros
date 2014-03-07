class CreateRelays < ActiveRecord::Migration
  def change
    create_table :relays do |t|
    	t.string :url
    	t.string :status
    	t.timestamps
    end
  end
end
