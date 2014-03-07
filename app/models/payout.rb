class Payout < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :worker_credit, :touch => true
	belongs_to :coin, :touch => true
	belongs_to :redemption, :touch => true
	has_one :round, :through => :worker_credit
	has_one :pool, :through => :round
	has_one :worker, :through => :worker_credit
	has_one :user, :through => :worker


	def self.unredeemed
		self.where(:is_redeemed => [false, nil])
	end

	def self.ready
		self.unredeemed.select {|payout| payout.ready? }
	end

	def self.ready_locked
		self.where(:is_redeemed => [false, nil]).lock(true).select {|payout| payout.ready? }
	end

	def self.confirmed
		self.unredeemed.select {|payout| payout.confirmed? }
	end

	def self.uncalculated
		self.where(:amount => nil)
	end

	# Payouts that are not redeemed but tied to a redemption
	def self.pending_redemption
		self.unredeemed.where.not(:redemption => nil)
	end

	def ready?
		self.round.state == "complete" and self.redemption == nil
	end

	def pending?
		self.round.state == "complete" and self.redemption != nil
	end

	def confirmed?
		self.round.state == "transferring" or self.round.state == "complete" and self.redemption == nil
	end

	def redeemed?
		self.is_redeemed?
	end

	def redeemed_string
		self.redeemed? ? "Yes" : "No"
	end

	def status_string
		if self.round.deposited?
			if self.round.fully_traded?
				return "Traded"
			else 
				return "Deposited to Cryptsy"
			end
		end
	end

	def amount_string
		return "%.8f" % self.estimated_or_real_amount
	end

	def estimated_or_real_amount
		if not self.amount.nil?
			return self.amount.to_f
		else
			return (self.round.estimated_earnings * self.worker_credit.percentage_of_work.to_f)
		end
	end

	def address_string
		return "Payout not redeemed" if not self.redeemed?
		return "Payout not redeemed" if self.redemption.nil?
		return self.redemption.address
	end

end

