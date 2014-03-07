class AddRoundToProfitabilityAnalytics < ActiveRecord::Migration
  def change
  	add_column :profitability_analytics, :round_id, :integer, references: :rounds
  	add_index :profitability_analytics, :round_id
  end
end
