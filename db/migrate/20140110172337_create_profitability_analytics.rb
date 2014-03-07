class CreateProfitabilityAnalytics < ActiveRecord::Migration
  def change
    create_table :profitability_analytics do |t|
      t.decimal :vwap
      t.integer :rating
      t.references :pool, index: true

      t.timestamps
    end
  end
end
