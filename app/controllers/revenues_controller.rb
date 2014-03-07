class RevenuesController < ApplicationController
	
  def index
  	
  end

  def show
  end

  private

  def coin_params
    params.required(:revenue).permit(:round, :amount, :address, :status)
  end
end
