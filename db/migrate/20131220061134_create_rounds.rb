class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.integer :coin_id
      t.string :url
      t.decimal :coins_earned
      t.decimal :btc_earned
      t.decimal :blocks
      t.decimal :shares
      t.integer :hash_rate_mhs
      t.integer :workers
      t.datetime :start
      t.datetime :end

      t.timestamps
    end

    add_index :rounds, :coin_id
  end
end
