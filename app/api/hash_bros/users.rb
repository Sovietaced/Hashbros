module HashBros
  class Users < Grape::API

    format :json
    # Enforce active model serialization
    formatter :json, Grape::Formatter::ActiveModelSerializers

    rescue_from :all, backtrace: true

    # Error handling
    rescue_from ActiveRecord::RecordNotFound do |e|
     rack_response('{ "status": 404, "message": "User Not Found." }', 404)
    end
      
    desc "Returns workers belonging to a user specified by their user id"
    get "/users/:id/workers"  do 
      user = User.find(params[:id])
      cache(key: "api:users:#{user.id}:workers", etag: user.updated_at, expires_in: 1.minutes) do
        return user.workers
      end
    end
  end
end