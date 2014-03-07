class API < Grape::API
  # Helpers must be loaded before the APIs are mounted
  helpers do
	def warden
	  env['warden']
	end

	def authenticated?
	  if warden.authenticated?
	    return true
	  elsif params[:auth_token] and
	    User.find_by_authentication_token(params[:auth_token])
	    return true
	  else
	    error!({"error" => "Unauthorized. Token invalid"}, 401)
	  end
	end

	def current_user
	  warden.user ||  User.find_by_authentication_token(params[:auth_token])
	end
  end

  include Grape::Rails::Cache
  
  mount HashBros::Coins
  mount HashBros::Profitability
  mount HashBros::Users
  mount HashBros::Workers

  # Routing catchall for 404 pages in general
  route :any, '*path' do
  	error! "Invalid API Endpoint"
  end
end