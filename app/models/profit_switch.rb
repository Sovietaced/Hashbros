class ProfitSwitch < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :pool
end
	