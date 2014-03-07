class WorkerHistory < ActiveRecord::Base
  default_scope { order(:id)}

  belongs_to :worker
  belongs_to :round

  def self.metrics_data(start_date=Date.today, end_date=DateTime.now)
  	# Only select pool hash rate with greater than 50 because of the big drops we see
  	# during the coin switches
  	# Also, if we change it in the future, we must keep it above 0 so that we don't have all
  	# the data for pools that weren't active.
    WorkerHistory.where(:created_at => start_date..end_date).reorder(id: :desc)
  end
end
