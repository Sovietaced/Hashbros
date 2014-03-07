class AddSimpleProfitabilityToCoinHistories < ActiveRecord::Migration
  def change
  	add_column :coin_histories, :simple_profitability, :float
  end
end
