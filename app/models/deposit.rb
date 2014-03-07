class Deposit < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :round, :touch => true
	belongs_to :worker_credit, :touch => true
	has_one :pool, :through => :round
	has_one :coin, :through => :round

	rails_admin do
    	exclude_fields :pool, :coin
  	end

	# If the deposit wasn't related to a worker credit, it was auto traded
	def self.auto_traded_and_pending
		self.where(:worker_credit_id => nil, :status => :submitted)
	end

	def self.failed
		self.where(:status => :failed)
	end

	def finished?
		return self.status == "finished"
	end

	def failed?
		return self.status == "failed"
	end
end

