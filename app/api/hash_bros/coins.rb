module HashBros
  class Coins < Grape::API

    format :json
    # Enforce active model serialization
    formatter :json, Grape::Formatter::ActiveModelSerializers

    rescue_from :all, backtrace: true

    include Grape::Rails::Cache

    # Error handling
    rescue_from ActiveRecord::RecordNotFound do |e|
     rack_response('{ "status": 404, "message": "Coin Not Found." }', 404)
    end

    namespace :coins do 
      
      desc "Returns all Coins"
      get "/" do
        cache(key: "api:coins", expires_in: 1.minutes) do
          return Coin.except_btc
        end
     end
    end
  end
end