class TimeStampForCoinHistories < ActiveRecord::Migration
  def change
  	add_column :coin_histories, :time, :datetime
  end
end
