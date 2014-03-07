class RedemptionsController < ApplicationController
	
  def index
  	
  end

  def show
    @redemption = Redemption.find(params[:id])
  end

  private

  def redemption_params
    params.required(:redemption).permit(:user, :coin, :is_processed, :amount, :address, :finished, :tx_hash, :state)
  end
end
