class HomeController < ApplicationController

  before_filter :authenticate_user!,
    :except => [:index, :faq, :contact, :profitability, :metrics]

  # CanCan Permissions
  authorize_resource :class => false, :only => [:test]

  def index
  	# Home page should be dashboard for logged in users
  	if current_user
      if current_user.enabled? or current_user.admin?
  		  return redirect_to action: :dashboard
      end
  	end
  end

  def dashboard
    # Do this to do the joins in just 1 query, not a bunch of others in the view
    @current_user = current_user
  end

  def leaderboard

  end

  def faq

  end

  def contact

  end

  def settings

  end

  def getting_started

  end

  def developers

  end

  def earnings
    @payouts = Payout.find(:all)
    @deposits = Deposit.find(:all)
  end

  def payouts
    @payouts = Payout.find(:all)
  end

  def deposits
    @deposits = Deposit.find(:all)
  end

  # Get coins with their latest coin history and sort by profitability
  def profitability
    @coin_histories = []
    @number_of_days = 7
    # Fix for #101. Will allow us to filter by coins only who are recently updated
    time_cut_off = 15.minutes.ago
    Coin.all.each do |coin|
      if !coin.coin_histories.last.nil? && coin.coin_histories.last.updated_at > time_cut_off
        @coin_histories.push(coin.coin_histories.last)
      end
    end
    @coin_histories.sort_by!(&:btc_per_day).reverse!
  end

  def metrics
  end
end
