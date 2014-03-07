class DebtsController < ApplicationController
	
  def index
  end

  def show
  	@debt = Debt.find(params[:id])
  	if not current_user.admin?
	  	return redirect_to controller: :home ,action: :dashboard if @debt.user != current_user
	  	return redirect_to controller: :home ,action: :dashboard if @debt.paid
	 end
  end

  def redeem
  	@debt = Debt.find(params[:id])
  	return redirect_to controller: :home ,action: :dashboard if @debt.user != current_user
  	return redirect_to controller: :home ,action: :dashboard if @debt.paid

  	response = Engine::PayoutEngine.pay_debt(@debt)
  	if response[:result] == :success
  		flash[:info] = 'Debt Paid!'
  		return redirect_to controller: :home ,action: :dashboard
  	else
  		flash[:error] = response[:result]
  		return redirect_to controller: :home ,action: :dashboard
  	end
  end

  private

  def coin_params
    params.required(:coin).permit(:name, :symbol,  :url, :difficulty, :exchange_address, :volume)
  end
end
