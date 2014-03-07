class PoolHistoriesController < ApplicationController


  private

  def pool_history_params
    params.required(:pool_history).permit(:pool, :round, :pool_hash_rate_mhs, :workers_count)
  end
end
