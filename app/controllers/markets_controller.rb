class MarketsController < ApplicationController

  private

  def market_params
   params.required(:market).permit(:exchange, :offer_coin, :sell_coin, :exchange_rate, :exchange_market_key)
  end
end
