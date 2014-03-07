class ProfitSwitchController < ApplicationController

  private

  def profit_switch_params
     params.required(:profit_switch).permit(:pool_id, :decision)
  end
end
