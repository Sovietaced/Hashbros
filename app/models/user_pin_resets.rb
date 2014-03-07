class UserPinResets < ActiveRecord::Base
  default_scope {order(:id)}
  belongs_to :user

  def is_valid?
  	# If we did not find a reset pin or if the pin was
    # created more than 15 minutes ago, it is not valid
    # or if it has already been used
  	return !(self.nil? || self.created_at <= 15.minutes.ago || self.used)
  end
end
