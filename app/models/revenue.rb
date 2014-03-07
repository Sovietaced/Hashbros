class Revenue < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :round
end
	