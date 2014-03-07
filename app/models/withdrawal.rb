class Withdrawal < ActiveRecord::Base
	default_scope { order(:id)}

	belongs_to :coin

end
	