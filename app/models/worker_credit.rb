class WorkerCredit < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :round, :touch => true
	belongs_to :worker, :touch => true
	has_one :user, :through => :worker
	has_many :payouts, :dependent => :destroy
	has_many :deposits, :dependent => :destroy

	def calculate_round_earnings
		# We may have to be careful about immature coins here
		self.round.total_coins_after_fees * self.round.pool.coin.exchange_rate.to_f * self.percentage_of_work
	end

	def percentage_of_work_string
		"%0.2f" % (self.percentage_of_work.to_f * 100) 
	end

	def percentage_of_work
		if round.accepted.to_i > 0
			return self.accepted_shares.to_f / round.accepted
		else 
			return 0
		end
	end

	def reject_rate
		total = self.rejected_shares.to_i + self.accepted_shares.to_i

		if total > 0
			return (self.rejected_shares / total.to_f) * 100
		end

		return 0
	end

	def coin
		# Traverse the relationships to get the coin for a given worker credit
		round = Round.find(self.round_id)
		pool = Pool.find(round.pool_id)
		return Coin.find(pool.coin_id)
		rescue ActiveRecord::RecordNotFound
			return nil
	end
end

