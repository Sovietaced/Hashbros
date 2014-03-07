class Block < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :round, :touch => true

	# Tells us if this block is mature
	def mature?
		self.category == "generate"
	end

	def immature?
		self.category == "immature"
	end

	def mature_string
		self.mature? ? "Mature" : "Immature" 
	end

	def orphan?
		self.category == "orphan"
	end

	def stale?
		self.category == "stale"
	end

	def amount_string
		if not self.orphan?
			return self.amount
		else
			return 0
		end
	end

	def status_string
		if self.mature?
			return "Mature"
		elsif self.immature?
			return "Immature"
		elsif self.orphan?
			return "Orphaned"
		else 
			return "Stale"
		end
	end
end
	