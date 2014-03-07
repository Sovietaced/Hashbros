# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# every 1.hours do
# 	rake "engine:auto_redeem"
# end

every 15.minutes do
	rake "engine:process_redemptions"
end

# We put this on its own separate task because it can't be delayed
 every 1.minutes do
 	rake "engine:update_coins"
 end

# Update worker stats every minute
 every 1.minutes do
   	rake "engine:run"
 end

# Update worker stats every minute
 every :day, :at => '12:00am' do 
   	rake "engine:withdraw"
 end
