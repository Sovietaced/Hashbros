class RelaysController < ApplicationController

  private

  def pool_params
   params.required(:relay).permit(:url, :status)
  end
end
