class Pool < ActiveRecord::Base

	belongs_to :coin

	scope :ordered, :joins => :coin, :order => "coins.name ASC"

	has_many :rounds, :dependent => :destroy
	has_many :worker_credits, :through => :rounds, :dependent => :destroy
	has_many :workers, :through => :worker_credits

	# Rails admins throws a bitch fit so I have to resctive has many through relationships
	rails_admin do
    	exclude_fields :worker_credits, :workers, :rounds
  	end

	def self.active_pools
		self.where(:is_active => true)
	end

	def self.active_and_online_pools
		self.active_pools.where(:is_online => true)
	end

	# These pool servers are used for profit switching
	def self.profit_switching_and_active
		self.active_and_online_pools.where(:is_profit_switch => true)
	end

	# These pool servers are used for ordinary mining
	def self.standalone_and_active
		# Using not since we want to handle false and nil
		self.active_pools.where(:is_profit_switch => false)
	end

	def average_purity
		return 1 if self.rounds.blank? 
		rounds = self.rounds.last(5)
		return rounds.collect(&:purity).sum.to_f / rounds.count
	end

	def active?
		is_active?
	end

	def online?
		is_online?
	end

	def profit_switch?
		is_profit_switch?
	end

	def stratum_url
		"stratum+tcp://#{self.url}:3333"
	end

	def time_to_find_block
		current_hash_rate = self.calculated_hash_rate_mhs.to_f

		if current_hash_rate > 0
			return (self.coin.difficulty.to_f * 2**32 / (self.calculated_hash_rate_mhs.to_f * 1000000.0)).to_i
		end
	end

	def time_to_find_block_string

		time = self.time_to_find_block
		if time.nil?
			return "Infinity"
		end

		return Time.at(time).strftime("%H:%M:%S")
	end


	def network_hash_rate_mhs
		self.coin.network_hash_rate.to_f / 1000000
	end

	def network_hash_rate_mhs_rounded
		return "%0.2f" % self.network_hash_rate_mhs
	end

	def current_hash_rate_mhs_rounded
		return "%0.2f" % self.calculated_hash_rate_mhs.to_f
	end

	# The pool hash rate / the network hash rate
	def current_hash_rate_mhs_percent
		return (self.calculated_hash_rate_mhs.to_f / self.network_hash_rate_mhs) * 100
	end

	def total_earnings
		sum = 0
		self.rounds.find_each { |round| sum += round.total_coins } #cast to integet for dem nil values
		return sum
	end

	def current_workers

		current_round = self.rounds.last
		active_workers = []

		if current_round
	    	current_round.workers.find_each do |worker|
	      		active_workers.push(worker) if worker.active?
	      	end
	    end

	    return active_workers
	end	
end

