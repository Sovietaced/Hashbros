class PoolsController < ApplicationController

  before_filter :authenticate_user!

  # CanCan Permissions
  load_and_authorize_resource

  def index
    # Only get the traditional pools
  	@pools = Pool.where.not("url like ?", "%ps-%")
  end

  def show
    @pool = Pool.find(params[:id])
  end

  private

  def pool_params
   params.required(:pool).permit(:calculated_hash_rate_mhs, :is_active, :is_profit_switch, :is_online)
  end
end
