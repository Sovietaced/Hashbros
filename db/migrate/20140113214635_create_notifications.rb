class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, null: false, index: true
      t.integer :category, null: false, index: true
      t.integer :target_id, null: false, index: true
      t.boolean :read, default: false, null: false, index: true

      t.timestamps
    end
  end
end
