class WorkerHistoriesController < ApplicationController


  private

  def worker_history_params
    params.required(:worker_history).permit(:worker, :round, :hash_rate_mhs, :difficulty)
  end
end
