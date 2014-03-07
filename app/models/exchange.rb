class Exchange < ActiveRecord::Base
	default_scope { order(:id)}

	has_many :markets

	validates_presence_of :name

	# Sexify
	rails_admin do
    	exclude_fields :markets
  	end
end
	