class RoundStatusEnum < ActiveRecord::Migration
  def change
  	 add_column :rounds, :state, :integer, default: 0
  end
end
