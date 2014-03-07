class UsersController < ApplicationController

  before_filter :authenticate_user!

  # CanCan Permissions
  load_and_authorize_resource

  def index
  end

  def show
    @user = User.find(params[:id])
  end

  def settings
    @coins = Coin.except_btc
    btc = Coin.where(:symbol => 'BTC').first
    @saved_user_coin_settings = UserCoinSetting.where(:user => current_user).where.not(coin_id: btc.id)
    @saved_user_coin_settings_hash = {}
    @saved_user_coin_settings.each do |setting|
        @saved_user_coin_settings_hash[setting.coin_id] = setting
    end
  end

  def save_settings
    user_coin_settings = params[:usercoinsettings]
    user_coin_settings.each do |key, user_coin_setting|
      setting = UserCoinSetting.where(:user_id => current_user, :coin_id => key).first
      if setting.nil?
        setting = UserCoinSetting.new
        setting.user = current_user
        setting.coin_id = key
      end
      if user_coin_setting.include? 'autotrade'
        setting.is_auto_trading = !!user_coin_setting['autotrade']
      else
        setting.is_auto_trading = false
      end
      setting.payout_address = user_coin_setting['address']
      setting.save!
    end
    redirect_to :action => 'settings'
  end

  def security

  end

  def edit_pin

  end

  def accept_user
    if current_user.admin?
      @user = User.find(params[:id])
      if not @user.admin? and not @user.is_enabled
        create_notification(@user, 'accepted', @user.id)
        @user.is_enabled = true;
        @user.save!
        flash[:notice] = 'Sent acceptance email'
        respond_to do |format|
          format.html { return redirect_to(:controller => 'users', :action => 'show', :user_id => @user) }
        end
      end
    end
    flash[:error] = 'Error while attempting to send acceptance email'
    respond_to do |format|
      format.html { return redirect_to controller: :home, action: :dashboard }
    end
  end

  def update_pin
    # Check to make sure the 2 pins passed in are the same
    if params[:new_pin] != params[:new_pin_confirmation]
      flash[:error] = 'New PINs must match!'
    end
    # Check to make sure the pin is 4 digits long
    if !(params[:new_pin] =~ /\d{4}$/)
      flash[:error] = 'New PIN must be 4 integer digits'
    end
    # Check to make sure the current PIN the user inputted
    # is the same as the one saved in the database
    if params[:current_pin].to_i != current_user.pin.to_i
      flash[:error] = 'Invalid current PIN'
    end
    # Ensure the password is valid
    if !current_user.valid_password?(params[:password])
      flash[:error] = 'Invalid password'
    end

    # As long as we hit no errors, we can update the pin
    if flash[:error].nil?
      current_user.pin = params[:new_pin]
      current_user.save!
      create_notification(current_user, 'pin_changed', 0)
      flash[:notice] = 'Successfully updated PIN'
    end
    redirect_to :action => :edit_pin
  end

  def load_setting

    @setting = UserCoinSetting.find_by(:coin_id => params[:coin_id], :user => current_user)

    # If this user does not have this setting yet, lets make it
    if not @setting
      @setting = UserCoinSetting.create!(:coin_id => params[:coin_id], :user => current_user, :is_auto_trading => true)
    end

    respond_to do |format|
      format.json { render :json => {
        :setting => @setting,
        :coin => { :transaction_fee => Coin.find(params[:coin_id]).transaction_fee }
        } and return }
    end
  end

  def update_redemption_settings
    if current_user
      current_user.update_attributes(:btc_threshold => params[:btc_threshold])
      flash[:notice] = "Auto redemption settings updated."
    else
      flash[:error] = "User not logged in."
    end

    redirect_to :action => :settings
  end

  def update_auto_trade_settings
    if current_user
      coin = Coin.find_by(:symbol => "BTC")
      setting = UserCoinSetting.find_by(:coin => coin, :user => current_user)
      if not setting
        setting = UserCoinSetting.create!(:coin => coin, :user => current_user, :is_auto_trading => true)
      end
      setting.update_attributes(:payout_address => params[:btc_address])
      flash[:notice] = "Auto trade settings updated."
    else
      flash[:error] = "User not logged in."
    end

    redirect_to :action => :settings
  end

  def update_coin_settings

      @setting = UserCoinSetting.find_by(:coin_id => params[:coin][:id], :user => current_user)
      coin = Coin.find(params[:coin][:id])

      if params[:exchange_address].blank?
        flash[:error] = "You can't enter an empty address!"
      # There should always be an existing settting.
      elsif @setting
        if not @setting.address_valid?(params[:exchange_address])
          flash[:error] = "Address is not valid, try again."
        else
          @setting.update_attributes(:payout_address => params[:exchange_address], :is_auto_trading => params[:is_auto_trading])

          @first_setting = UserCoinSetting.find_by(:coin => Coin.first, :user => current_user)
          create_notification(current_user, 'payout_address_changed', coin.id)
          flash[:notice] = "Settings successfully updated for " + coin.name

        end
      end
      redirect_to :action => :settings
  end

  def get_user_dashboard_info
    response = {:status => 'error', :message => 'No user logged in'}
    @current_user = current_user
    response = {
      :status => 'success',
      :message => 'Successfully fetched updated user stats',
      :data => {
        :hash_rate => @current_user.current_hashrate(@current_user.current_workers),
        :workers_count => @current_user.current_workers,
        :markup => {
          :visits_info => render_to_string(:partial => "partials/visits_info"),
          :pool_stats => render_to_string(:partial => "partials/pool_stats", :locals => {
            :current_coin => Engine::ProfitSwitchEngine.current_coin,
            :current_pool => Engine::ProfitSwitchEngine.current_pool,
            :current_round => Engine::ProfitSwitchEngine.current_round
          }),
          :user_latest_rounds => render_to_string(:partial => "partials/user_latest_rounds"),
          :hashbros_basic_stats => render_to_string(:partial => 'partials/basic_stats'),
        }
      }
    }
    respond_to do |format|
      format.json {
        render :json => response
      }
    end
  end

  def payouts
      @payouts = current_user.payouts
  end

  def redeem

    pin = params[:pin]
    password = params[:password]
    gauth_code = params[:gauth_code]

    authenticated = current_user.reauthenticate(pin, password, gauth_code)
    if authenticated[:status] != 'success'
      flash[:error] = "You have not properly authenticated"
      return redirect_to controller: :users, action: :earnings
    end

    response = Engine::RedemptionEngine.create_redemption(current_user)

    if response[:result] == :success
      # Manually expire cached page to reflect new results
      expire_fragment("#{current_user.id}:earnings")
      flash[:info] = response[:message]
    else
      flash[:error] = response[:message]
    end

    redirect_to controller: :users ,action: :earnings
  end

  def deposits
    @deposits = current_user.deposits
  end

  def earnings
    @payouts =  current_user.payouts.reorder(id: :desc).page(params[:payouts_page])
    @deposits = current_user.deposits.reorder(id: :desc).page(params[:deposits_page])
  end

  def redemptions
    @pending_redemptions = current_user.redemptions.without_state(:processed).reorder(id: :desc)
    @paid_redemptions = current_user.redemptions.with_state(:processed).reorder(id: :desc).page(params[:redemptions_page])
  end

  def rounds
    @user = User.find(params[:user_id])
    @rounds = Kaminari.paginate_array(@user.rounds.reorder(id: :desc).uniq).page(params[:page])
  end

  def load_reauthenticate_modal
    modal_markup = render_to_string(:partial => "/partials/verify_credentials_modal")
    respond_to do |format|
      format.json {
        render :json => {
          :status => 'success',
          :message => 'Created the modal',
          :data => {
            :modal_markup => modal_markup
          }
        }
      }
    end
  end

  def reauthenticate
    # Grab the POSTed data
    pin = params[:pin]
    password = params[:password]
    gauth_code = params[:gauth_code]

    result = current_user.reauthenticate(pin, password, gauth_code)

    respond_to do |format|
      format.json { render :json => result and return }
    end
  end

  def forgot_pin

  end

  def reset_pin
    success = current_user.reset_pin
    if success
      user_pin_reset = current_user.latest_reset_pin
      if user_pin_reset.nil?
        flash[:error] = 'Error while generating PIN reset instructions'
      else
        UserMailer.reset_pin_instructions(current_user, user_pin_reset).deliver
        flash[:success] = 'Successfully sent PIN reset instructions'
      end
    else
      flash[:error] = 'Error while sending PIN reset instructions, please try again in a few minutes'
    end
    redirect_to controller: :users, action: :security
  end

  def reset_pin_form
    code = params[:code]
    reset_pin = UserPinResets.where(code: code, user: current_user).first
    if !reset_pin.is_valid?
      flash[:error] = 'PIN reset code is not valid or has expired'
      return redirect_to controller: :users, action: :security
    end
  end

  def set_pin
    code = params[:code]
    reset_pin = UserPinResets.where(code: code, user: current_user).first
    if !reset_pin.is_valid?
      flash[:error] = 'PIN reset code is not valid or has expired'
      return redirect_to controller: :users, action: :security
    end
    # Check to make sure the 2 pins passed in are the same
    if params[:new_pin] != params[:new_pin_confirmation]
      flash[:error] = 'New PINs must match!'
      return redirect_to controller: :users, action: :reset_pin_form
    end
    # Check to make sure the pin is 4 digits long
    if !(params[:new_pin] =~ /\d{4}$/)
      flash[:error] = 'New PIN must be 4 integer digits'
      return redirect_to controller: :users, action: :reset_pin_form
    end

    current_user.pin = params[:new_pin]
    update_user = current_user.save!
    reset_pin.used = true
    update_reset_pin = reset_pin.save!
    if update_user && update_reset_pin
      flash[:success] = 'Successfully updated PIN!'
      create_notification(current_user, 'pin_changed', 0)
    else
      flash[:error] = 'Error while updating PIN, please try again'
    end
    return redirect_to controller: :users, action: :security
  end

  def test_2fa
    result = {:status => 'error', :message => 'Invalid 2FA code'}
    gauth_code = params[:gauth_code]
    if current_user.validate_token_no_tmp_datetime(gauth_code)
      result = {:status => 'success', :message => 'Successfully validated 2FA code'}
    end
    respond_to do |format|
      format.json { render :json => result and return }
    end
  end

  private

  def user_params
    params.required(:user).permit(:username, :email, :password, :gauth_token, :btc_threshold, :ltc_threshold)
  end
end
