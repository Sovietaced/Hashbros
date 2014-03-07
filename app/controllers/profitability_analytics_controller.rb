class ProfitabilityAnalyticsController < ApplicationController
	def index
		if current_user.admin?
			@pas = ProfitabilityAnalytics.includes(:pool).order(:id).reverse_order.page(params[:page])
		end
	end
end
