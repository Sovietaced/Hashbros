class Redemption < ActiveRecord::Base
	extend Enumerize
	default_scope { order(:id)}

	''' RELATIONS '''
	belongs_to :user, :touch => true
	belongs_to :coin
	has_many :payouts

	''' RAILS ADMIN'''
	# Rails admins throws a bitch fit so I have to resctive has many through relationships
	rails_admin do
    	exclude_fields :payouts
  	end

  	''' ENUMERIZE '''
	enumerize :state, in: { unprocessed: 0, processing: 1, processed:2, failed: 3}, scope: true, default: :unprocessed

	def update_state(state)
		self.state = state
		self.save!
	end

	''' CALLBACKS '''
	after_create :send_notification_email

	def send_notification_email
		UserMailer.redemption_requested(self.user).deliver
	end

	''' OTHER '''
	def unprocessed?
		self.state == "unprocessed"
	end

	def processing?
		self.state == "processing"
	end

	def processed?
		self.state == "processed"
	end

	def failed?
		self.state == "failed"
	end

	def state_string
		return "Unprocessed" if self.unprocessed?
		return "Processing" if self.processing?
		return "Processed" if self.processed?
		return "Failed" if self.failed?
	end

	def tx_hash_string
		self.processed? ? self.tx_hash : "Not Processed"
	end

	def finished_string
		self.processed? ? self.finished : "Not Processed"
	end
end

