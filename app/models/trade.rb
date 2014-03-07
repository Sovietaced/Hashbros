class Trade < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :order, :touch => true

	def self.amount_before_fees
		self.price * self.quantity
	end

end
	