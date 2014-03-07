class DeleteRoundHistories < ActiveRecord::Migration
  def change
  	drop_table :round_histories
  end
end
