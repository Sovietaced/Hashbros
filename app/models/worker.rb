class Worker < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :user, :touch => true
	has_many :worker_credits, :dependent => :destroy
	has_many :rounds, :through => :worker_credits
	has_many :worker_histories

	# Rails admins throws a bitch fit so I have to resctive has many through relationships
	rails_admin do
    	exclude_fields :worker_credits, :rounds, :worker_histories
  	end

	# We know a worker is active if their work history has been recently updated
	def active?
		return (Time.now - self.updated_at) < 5.minutes
	end

	def active_string
		self.active? ? "YES" : "NO"
	end

	def last_pool
		return nil if self.worker_credits.blank?
		return nil if self.worker_credits.last.round.nil?
		return self.worker_credits.last.round.pool if not self.worker_credits.last.round.pool.nil?
	end

	def hash_rate_mhs_round
		if self.active? && !hash_rate_mhs.nil?
			return "%0.2f" % hash_rate_mhs
		else
			return 0
		end
	end

	# Checks the last round involved in
	def profit_switch?
		return false if self.rounds.blank?
		return true if self.rounds.last.pool.profit_switch? and active?
		return false
	end

	# Returns the status of profit switching as a string for display
	def profit_switch_string
		self.profit_switch? ? "ON" : "OFF"
	end

	def last_coin_string
		if self.active? && !self.last_pool.nil?
			return self.last_pool.coin.symbol
		else
			return "None"
		end
	end

	def last_coin
		return nil if self.last_pool.nil?
		self.last_pool.coin
	end

	def difficulty_string
		self.active? ? difficulty : 0
	end

	def reject_rate
		credits = self.worker_credits

		if not credits.blank?
			return self.worker_credits.last.reject_rate
		end

		return 0
	end
end
