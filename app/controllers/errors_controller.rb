class ErrorsController < ApplicationController
	def error_404
		# No matter where we are, set the param controller to errors
		# so that the layout view knows that we're on an error page
		params[:controller] = 'errors'
	end

	def error_500
		# No matter where we are, set the param controller to errors
		# so that the layout view knows that we're on an error page
		params[:controller] = 'errors'
	end
end
