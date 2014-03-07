class CreateCoinHistories < ActiveRecord::Migration
  def change
    create_table :coin_histories do |t|
      t.integer :volume, index: true
      t.float :diff, index: true
      t.decimal :max, index: true
      t.decimal :min, index: true
      t.decimal :last_price, index: true
      t.belongs_to :coin, index: true

      t.timestamps
    end
  end
end
