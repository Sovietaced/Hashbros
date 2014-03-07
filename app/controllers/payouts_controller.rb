class PayoutsController < ApplicationController


  private

  def pool_params
   params.required(:payout).permit(:worker_credit, :coin, :redemption, :is_redeemed, :fees )
  end
end
