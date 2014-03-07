class WithdrawalsController < ApplicationController

	# CanCan Permissions
  authorize_resource :class => false

  def index

  end

  def show
  	
  end

  def create
  	@coin = Coin.btc
    @withdrawal = Withdrawal.create!(:amount => params[:withdrawal][:amount], :coin => @coin)

    if @withdrawal
      if Engine::PayoutEngine.withdraw
	      flash[:success] = 'Successfully submitted withdrawal.'
	      return redirect_to :action => 'index'
	  else
	  	flash[:alert] = 'Round update failed'
	    return redirect_to :action => 'index'
	  end
    else
      return redirect_to :action => 'withdraw'  
    end
  end

  def new
  	@withdrawal = Withdrawal.new
  end

  private

  def withdrawal_params
    params.required(:withdrawal).permit(:amount, :coin)
  end
end
