module NotificationsHelper
	def create_notification(user, category, target_id)
		# The purpose of using this function over just the standard way of creating
		# a new instance of a model is to simultaneously send off an email if needed

		# By default, we will always create a notification (duh)
		Notifications.create!(:user => user, :category => category, :target_id => target_id)

		# But here are the cases in which we'll send an email
		if category == 'redemption'
			UserMailer.redemption_requested(user).deliver
		elsif category == 'accepted'
			UserMailer.beta_accepted_email(user).deliver
		elsif category == 'pin_changed'
			UserMailer.pin_changed(user).deliver
		elsif category == 'payout_address_changed'
			coin = Coin.find(target_id)
			UserMailer.payout_address_changed(current_user, coin).deliver
		end
	end
end
