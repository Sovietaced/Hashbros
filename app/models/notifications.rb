class Notifications < ActiveRecord::Base
	extend Enumerize
	belongs_to :user

	default_scope {order(:id)}

	enumerize :category, in: {
		redemption: 0,
		login: 1,
		payout_ready: 2,
		accepted: 3,
		pin_changed: 4,
		payout_address_changed: 5,
	}, scope: true, default: :login

	def generate_string
		if self.category == 'redemption'
			return 'Account Redemption'
		elsif self.category == 'login'
			return 'Account Login'
		elsif self.category == 'payout_ready'
			return 'You have a payment ready to be redeemed'
		elsif self.category == 'accepted'
			return 'Account Activated!'
		elsif self.category == 'pin_changed'
			return 'PIN Change'
		elsif self.category == 'payout_address_changed'
			return 'Address Change'
		end
	end

	def generate_icon
		if self.category == 'redemption'
			return '<span class="label label-important"><i class="fa fa-bell-o"></i></span>'
		elsif self.category == 'login'
			return '<span class="label label-info"><i class="fa fa-info-circle"></i></span>'
		elsif self.category == 'payout_ready'
			return '<span class="label label-success"><i class="fa fa-bitcoin"></i></span>'
		elsif self.category == 'accepted'
			return '<span class="label label-success"><i class="fa fa-lightbulb-o"></i></span>'
		elsif self.category == 'pin_changed'
			return '<span class="label label-danger"><i class="fa fa-lock"></i></span>'
		elsif self.category == 'payout_address_changed'
			return '<span class="label label-danger"><i class="fa fa-lock"></i></span>'
		end
	end

	def generate_link
		if self.category == 'redemption'
			return '/earnings'
		elsif self.category == 'login'
			return '/users/settings/security'
		elsif self.category == 'payout_ready'
			return '/earnings'
		elsif self.category == 'accepted'
			return '/'
		elsif self.category == 'pin_changed'
			return '/users/settings/security'
		elsif self.category == 'payout_address_changed'
			return '/settings'
		end
	end

end
