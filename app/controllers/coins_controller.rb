class CoinsController < ApplicationController

  def index
  	@coins = Coin.all
    @coins.delete_if {|coin| coin.symbol == "BTC"}
  end

  def show
    @coin = Coin.find(params[:id])
    @number_of_days = 7
  end

  private

  def coin_params
    params.required(:coin).permit(:name, :symbol,  :url, :difficulty, :exchange_address, :blocks, :network_hash_rate, :exchange_rate)
  end
end
