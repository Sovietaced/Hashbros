class Round < ActiveRecord::Base
		extend Enumerize
	default_scope { order(:id)}

	# This is for the full lifecycle of an auto trading round
	# 1 Switched
	# 2 Attempted to deposit to Cryptsy and user wallets
	# 3 Deposit received by Cryptsy
	# 4 Sell orders created
	# 5 Sell orderes finished and complete
	# 6 Sending from Cryptsy to our wallet
	# 7 Complete
	enumerize :state, in: { running: 0, over: 1, matured:2, deposited: 3, deposits_finished: 4, selling: 5, exchanged: 6, transferring: 7, complete: 8}, scope: true, default: :running

	def update_enum(state)
		self.state = state
		self.save!
	end

	belongs_to :pool, :touch => true
	has_one :coin, :through => :pool
	has_many :orders, :dependent => :destroy
	has_many :trades, :through => :orders
	has_many :blocks, :dependent => :destroy
	has_many :worker_credits, :dependent => :destroy
	has_many :workers, :through => :worker_credits
	has_many :payouts, :through => :worker_credits, :dependent => :destroy
	has_many :deposits, :dependent => :destroy

	# Rails admins throws a bitch fit so I have to resctive has many through relationships
	rails_admin do
    	exclude_fields :worker_credits, :blocks, :deposits, :workers
  	end

	# Default pagination size
	paginates_per 25

	''' Static '''
	PROFIT_SWITCH_FEE = 0.015

	''' Methods for getting models '''
	# Gets the current profit switching round
	def self.current
		Round.find_all_by_pool_id(Pool.profit_switching_and_active.pluck(:id)).max
	end

	# Gets all active rounds that haven't ended
	def self.active
		Round.where(:end => nil)
	end

	def self.immature
		self.over.delete_if {|round| round.matured? }
	end

	# Get rounds with finished deposits that haven't been traded
	def self.untraded
		self.auto_traded_deposit_unfinished.delete_if {|round| round.fully_traded?}
	end

	# Get rounds with deposits that haven't been traded
	def self.fully_traded
		self.deposited.delete_if {|round| not round.fully_traded?}
	end

	# Get rounds where payouts have no been calculated yet
	def self.uncalculated
		uncalculated = []
		self.fully_traded.each do |round|
			if not round.payouts.uncalculated.blank?
				uncalculated.push(round)
			end
		end
	end

	def self.traded
		self.deposited.delete_if {|round| round.trades.blank? }
	end

	def self.auto_traded_deposit_finished?
		self.all.select {|round| round.auto_traded_deposit_finished? }
	end

	def self.rounds_in_period_of_time(start_date=Date.today-1, end_date=Date.today)
		Round.where(:created_at => start_date..end_date).order('id DESC')
	end

	def worker_credits_by_percentage_of_work
		self.worker_credits.sort_by{|credit| -credit.percentage_of_work}
	end

	def time
		if self.end
			Time.diff(self.start, self.end, '%y, %d and %h:%m:%s')[:diff]
		else
			Time.diff(self.start, Time.now, '%y, %d and %h:%m:%s')[:diff]
		end
	end

	''' Block Methods '''
	def time_to_find_block_percent

		time_to_find_block = self.pool.time_to_find_block.to_i

		if time_to_find_block > 0
			return "%0.2f" % ((self.time_on_last_block / time_to_find_block.to_f) * 100)
		else
			return "0"
		end
	end

	def time_on_last_block
		block = self.blocks.last

		if block
			return Time.now.to_i - block.created_at.to_i
		else
			# if no blocks exist we compare against the beginning of the round
			return Time.now.to_i - self.created_at.to_i
		end
	end

	def blocks_updated?
		if self.end
			self.blocks.find_each do |block|
				return false if block.immature?
			end
			return true
		end
	end

	''' Deposit Methods '''

	def audit
		worker_shares_count = self.worker_credits.reduce(0) { |sum, worker_credit| sum + worker_credit.accepted_shares }
		self.update_attributes(:accepted => worker_shares_count)
	end

	def deposits_finished?
		self.deposits.find_each do |deposit|
			return false if not deposit.finished?
		end
		return true
	end

	def accept_rate
		return "%0.2f" % (100 - self.reject_rate.to_f)
	end

	def estimated_earnings_string
		if self.pool.profit_switch?
			return ("%0.6f" % self.estimated_earnings) + " BTC"
		else
			return self.total_coins.to_s + " #{self.pool.coin.symbol}"
		end
	end

	def estimated_earnings
		return (self.total_coins_after_fees * self.pool.coin.exchange_rate.to_f).to_f
	end

	def estimated_or_real_earnings
		if self.state_value == 8
			return self.btc_traded
		else
			return self.estimated_earnings
		end
	end

	def estimated_earnings_for_user(user)
		worker_credits = user.worker_credits.where(:round => self)

		if not worker_credits.blank?
			return self.estimated_earnings * worker_credits.reduce(0) {|sum, credit| sum + credit.percentage_of_work.to_f }
		end
		return 0
	end

	def estimated_earnings_for_user_string(user)
		est_earnings_for_user = self.estimated_earnings_for_user(user)
		if est_earnings_for_user > 0
			return ("%0.6f" % est_earnings_for_user) + " BTC"
		else
			return "N/A"
		end
	end

	''' Round Overview Methods '''

	# Determines if a round is over or not
	def over?
		end?
	end

	def state_string
		case self.state_value
		when 0
		  return "Running"
		when 1
		  return "Maturing"
		when 2
		  return "Matured"
		when 3
		  return "Deposits Sent"
		when 4
		 return "Deposits Arrived"
		when 5
		  return "Trading"
		when 6
		  return "Traded"
		when 7
		  return "Awaiting Withdrawal"
		when 8
		  return "Finished"
		else
		  return "None"
		end
	end

	# Used to determine if the round is ready to process deposits
	def matured?
		self.mature_coins.to_f == self.total_coins.to_f
	end

	def mature_string
		self.matured? ? "Mature" : "Immature"
	end

	# We know the coins for this round have been processed if there are deposits for this round
	def deposited?
		not self.deposits.blank?
	end

	def deposited_string
		self.deposited? ? "Yes" : "No"
	end

	# Determines if all the trades are close to equal to the initial auto traded deposit's confirmed amount
	def fully_traded?
		# The optimal amount have been traded
		fully_traded_amount = self.auto_traded_deposit.confirmed_amount.to_f
		one_percent = fully_traded_amount * 0.01
		# Calculate ranges
		under = (fully_traded_amount - one_percent).round(2)
		over = (fully_traded_amount + one_percent).round(2)
		# Check if the coins traded are withing plus or minus 1 percent of the coins traded
		return (under..over).include?(self.coins_traded.round(2))
	end

	def fully_cancelled?
		self.orders.each do |order|
			return false if not order.cancelled?
		end
		return true
	end

	# This is the amount of resulting BTC we have successfully traded our coins for
	def btc_traded
		return self.trades.reduce(0) { |sum, trade| sum + trade.total_btc.to_f }
	end

	# THis is the amount of coins we have successfully traded for btc
	def coins_traded
		return self.trades.reduce(0) { |sum, trade| sum + trade.quantity.to_f }
	end

	# Returns all finished rounds with matured coins that haven't been deposited
	def self.pending_deposits
		rounds = []
        Round.each do |round|
           if round.total_coins > 0 and round.matured? and round.over? and not round.deposited?
                   rounds.push(round)
           end
        end
        return rounds
	end

	# There should be only one deposit each round that goes to our cryptsy address
	def auto_traded_deposit
		self.deposits.find_by(:exchange_address => self.pool.coin.cryptsy_address)
	end

	def auto_traded_deposit_finished?
		self.auto_traded_deposit.finished?
	end

	# Percentage of blocks mined that yielded coins
	def purity
		return 1 if self.blocks.blank?
		return self.blocks.select{|block| not block.orphan?}.count / self.blocks.count.to_f
	end

	''' Round Coin Methods '''

	# Mature coins are coins that have been transferred to our wallet
	def mature_coins
		sum = 0
		self.blocks.find_each { |block| sum += block.amount if block.mature?} #cast to integet for dem nil values
		return sum
	end

	# Immature coins are those which have not been transferred to our wallet yet. Blocks have been found however..
	def immature_coins
		sum = 0
		self.blocks.find_each { |block| sum += block.amount if block.immature? } #cast to integet for dem nil values
		return sum
	end

	# Both mature and immature coins
	def total_coins
		self.mature_coins + self.immature_coins
	end

	def total_coins_after_fees
		if self.pool.profit_switch?
			return self.total_coins - (self.total_coins * PROFIT_SWITCH_FEE)
		else
			return self.total_coins - (self.total_coins * PROFIT_SWITCH_FEE)
		end
	end

	def total_fees
		self.total_coins - self.total_coins_after_fees
	end

	def total_coins_auto_traded

	end

	def mature_coins_percent
		# Avoid divide by zero
		return 0 if self.total_coins == 0
		return (self.mature_coins / self.total_coins) * 100
	end

	def state_to_percentage
		return (self.state_value + 2) * 10
	end

	def average_hashrate
		PoolHistory.where(:round_id => self.id).average(:pool_hash_rate_mhs)
	end

	def btc_per_mh
		if self.end.nil?
			return (self.estimated_or_real_earnings.to_f / self.average_hashrate.to_f) / ((Time.now - self.start) * 60)
		else
			return (self.estimated_or_real_earnings.to_f / self.average_hashrate.to_f) / ((self.end - self.start) * 60)
		end
	end
end
