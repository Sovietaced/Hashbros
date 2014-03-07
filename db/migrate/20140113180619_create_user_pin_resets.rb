class CreateUserPinResets < ActiveRecord::Migration
  def change
    create_table :user_pin_resets do |t|
      t.references :user, index: true
      t.string :code
      t.boolean :used

      t.timestamps
    end
  end
end
