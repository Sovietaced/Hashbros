class ExchangesController < ApplicationController

  private

  def exchange_params
   params.required(:exchange).permit(:name)
  end
end
