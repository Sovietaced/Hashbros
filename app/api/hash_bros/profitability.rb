module HashBros
  class Profitability < Grape::API

    format :json
    # Enforce active model serialization
    formatter :json, Grape::Formatter::ActiveModelSerializers

    rescue_from :all, backtrace: true

    # Error handling
    rescue_from ActiveRecord::RecordNotFound do |e|
     rack_response('{ "status": 404, "message": "Coin Not Found." }', 404)
    end

    namespace :profitability do 
      
      desc "Returns all coin histories"
      get "/" do
        cache(key: "api:profitability", expires_in: 1.minutes) do
          @coin_histories = []
          Coin.except_btc.each do |coin|
            @coin_histories.push(coin.coin_histories.last) if not coin.coin_histories.last.nil?
          end
          @coin_histories.sort_by!(&:btc_per_day).reverse!
          return @coin_histories
        end
      end
    end
  end
end