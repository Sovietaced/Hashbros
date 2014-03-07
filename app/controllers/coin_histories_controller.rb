class CoinHistoriesController < ApplicationController

  def index
    if current_user.admin?
      @coin_histories = CoinHistory.all(:joins => :coin)
      respond_to do |format|
        format.html do
          response.headers['Content-Type'] = 'text/csv'
          response.headers['Content-Disposition'] = 'attachment; filename=coin_history.csv'
          render :layout => false
        end
      end
    end
  end

  def show
  end

  private

  def coin_history_params
    params.required(:coin_history).permit(:coin, :diff, :ask, :bid, :liquidity_premium, :depth, :profitability, :blocks, :btc_per_day, :network_hash_rate, :exchange_rate)
  end
end
