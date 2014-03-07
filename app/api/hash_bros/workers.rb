module HashBros
  class Workers < Grape::API

    format :json
    # Enforce active model serialization
    formatter :json, Grape::Formatter::ActiveModelSerializers

    rescue_from :all, backtrace: true

    # Error handling
    rescue_from ActiveRecord::RecordNotFound do |e|
     rack_response('{ "status": 404, "message": "Worker Not Found." }', 404)
    end

    namespace :workers do 
      
      desc "Return worker specified by id"
      get "/:id" do
        worker = Worker.find(params[:id])
        cache(key: "api:workers:#{worker.id}", etag: worker.updated_at, expires_in: 1.minutes) do
          return worker
        end
      end
    end
  end
end