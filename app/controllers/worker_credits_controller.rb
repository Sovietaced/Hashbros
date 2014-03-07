class WorkerCreditsController < ApplicationController

  def index

  end

  def show
  	
  end

  private

  def worker_params
    params.required(:worker_credit).permit(:worker, :round, :accepted_shares, :rejected_shares, :reject_rate)
  end
end
