class PoolHistory < ActiveRecord::Base
  include ModelHelper
  default_scope { order(:id)}

  belongs_to :pool
  belongs_to :round

  def self.metrics_data(start_date=Date.today-1, end_date=DateTime.now)
  	# Only select pool hash rate with greater than 50 because of the big drops we see
  	# during the coin switches
  	# Also, if we change it in the future, we must keep it above 0 so that we don't have all
  	# the data for pools that weren't active.
    PoolHistory.where(:created_at => start_date..end_date).where('pool_hash_rate_mhs > 30').reverse
  end

  def self.average_hashrate_for_range(start_date=Date.today-1, end_date=Date.today)
    averages = PoolHistory.where(:created_at => start_date..end_date).where('pool_hash_rate_mhs > 30').average(:pool_hash_rate_mhs)
    if averages.nil?
      return 0.0
    else
      return averages
    end
  end

  def self.metric_data_for_range(start_date=Date.today-1, end_date=Date.today)
    average_hash_rate = PoolHistory.average_hashrate_for_range(start_date, end_date)
    metrics_data = PoolHistory.metrics_data(start_date, end_date)
    round_data = Round.rounds_in_period_of_time(start_date, end_date)
    estimated_btc = 0.0
    temp_earnings_data = []
    round_data.each do |earning|
      temp_earnings_data.push({
        :created_at => earning.created_at,
        :estimated_earnings => earning.estimated_or_real_earnings
      })
      estimated_btc += earning.estimated_or_real_earnings
    end
    return {
      :start_date => start_date,
      :end_date => end_date,
      :estimated_btc => estimated_btc,
      :btc_per_mh => estimated_btc / average_hash_rate,
      :average_hash_rate => average_hash_rate,
      :earnings_data => temp_earnings_data,
      :metrics_data => metrics_data,
    }
  end
end
