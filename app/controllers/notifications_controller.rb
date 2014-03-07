class NotificationsController < ApplicationController

	before_filter :authenticate_user!

	def mark_all_as_read
		notifs = current_user.unread_notifications
		notifs.each do |notif|
			notif.read = true
			notif.save!
		end

		respond_to do |format|
			format.json {
				render :json => {
					:status => 'success',
					:message => 'Successfully marked notifications as read',
				}
			}
		end
	end

	def all
		@notifications = current_user.all_notifications
	end

	def poll
		notifications = current_user.unread_notifications
		response = {
			:status => 'success',
			:message => 'Successfully fetched updated notifications',
			:data => {
				:count => notifications.length,
				:notifications => notifications,
				:markup => render_to_string(:partial => '/notifications/menu'),
			}
		}

		respond_to do |format|
			format.json {
				render :json => response
			}
		end
	end
end
