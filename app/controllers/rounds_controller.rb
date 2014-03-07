class RoundsController < ApplicationController

  before_filter :authenticate_user!

  # CanCan Permissions
  load_and_authorize_resource

  def index
    @rounds = Round.order(:start).reverse_order.page(params[:page])
  end

  def show
    @user = current_user
  	@round = Round.find(params[:id])
  end

  private

  def round_params
    params.required(:round).permit(:coins_earned, :btc_earned, :blocks, :shares, :start, :end, :accepted, :rejected, :state)
  end
end
