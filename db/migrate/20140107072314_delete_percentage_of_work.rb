class DeletePercentageOfWork < ActiveRecord::Migration
  def change
  	remove_columns :worker_credits, :percentage_of_work
  end
end
