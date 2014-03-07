class Order < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :round, :touch => true
	has_many :trades, :dependent => :destroy

	# Pending orders are those that are submited and not cancelled
	def self.submitted
		Order.where(:status => :submitted)
	end

	def self.cancelled
		Order.where(:status => :cancelled)
	end

	def complete?
		self.trades.reduce(0) { |sum, trade| sum + trade.quantity.to_f } == self.quantity.to_f
	end

	def old?
		(Time.now - self.created_at) > 30.minutes 
	end

	def cancelled?
		self.status == "cancelled"
	end

end
	