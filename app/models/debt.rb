class Debt < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :user
end
	