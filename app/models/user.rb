class User < ActiveRecord::Base
	attr_accessor :gauth_token
  default_scope { order(:id)}
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :google_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :workers, :dependent => :destroy
  has_many :worker_credits, :through => :workers
  has_many :rounds, :through => :worker_credits
  has_many :payouts, :through => :worker_credits
  has_many :user_coin_settings
  has_many :deposits, :through => :worker_credits
  has_many :debts
  has_many :redemptions
  has_many :worker_histories, :through => :workers

  validates_length_of :pin, :minimum => 4, :maximum => 4, :allow_blank => false
  validates :username, :presence => true

  #Uncomment to send welcome emails on registration
  #after_create :send_welcome_email

  # Rails admins throws a bitch fit so I have to resctive has many through relationships
  rails_admin do
    exclude_fields :worker_credits, :workers, :rounds, :payouts, :user_coin_settings, :deposits, :debts, :redemptions, :worker_histories
  end

  after_create :enable_user

  def enable_user
    self.is_enabled = true
    self.save!
  end

  def self.enabled
    User.where(:is_enabled => true)
  end

  def enabled?
    self.is_enabled?
  end

  def estimated_balance(payouts = self.payouts.unredeemed)
    payouts.reduce(0) { |balance, payout| balance + payout.estimated_or_real_amount }
  end

  def confirmed_balance(payouts = self.payouts.confirmed)
    payouts.reduce(0) { |balance, payout| balance + payout.amount.to_f }
  end

  def confirmed_balance_string(payouts = self.payouts.confirmed)
     "%.8f" % confirmed_balance
  end

  def estimated_balance_string(estimated_balance = self.estimated_balance)
    "%.8f" % estimated_balance
  end

  def balance(payouts = self.payouts.ready)
    payouts.reduce(0) { |balance, payout| balance + payout.amount.to_f }
  end

  def balance_string(balance = self.balance)
    "%.8f" % balance
  end

  def pending_redemption

  end

  def estimated_daily_earnings_string
    daily_payouts = self.payouts.where(created_at: 1.day.ago..DateTime.now)

    if not daily_payouts.blank?
      first_payout = daily_payouts.first
      multiply_for_day = 1.day.to_f / (Time.now.to_i - first_payout.created_at.to_i)

      sum = daily_payouts.reduce(0) {|sum, payout| sum + payout.estimated_or_real_amount}

      return "%.8f" %  (sum * multiply_for_day)
    end
    return "%.8f" % 0
  end

  def self.ranked_by_shares
    return User.where(:is_enabled => true).find(:all, :include => :worker_credits).sort_by{|user| -user.all_time_shares(user.worker_credits)}
  end

  def self.ranked_by_hashrate
    return User.where(:is_enabled => true).find(:all, :include => :workers).sort_by{|user| -user.current_hashrate(user.current_workers)}
  end

  def admin?
    is_admin?
  end

  def unpaid_debts
    self.debts.select {|debt| not debt.paid}
  end

  # Check if this user is currenctly deciding to auto trade a coin or not
  def auto_trading?(coin)
    setting = UserCoinSetting.where(:user => self, :coin => coin).first
    return setting.auto_trading? if not setting.nil?
    # If they don't seem to have created any settings we default to auto trading
    return true
  end

  def btc_address
    self.address_for(Coin.find_by(:symbol => "BTC"))
  end

  def current_hashrate(workers = self.current_workers)
    hashrate = 0.0
    workers.each do |worker|
      hashrate += worker.hash_rate_mhs if !worker.hash_rate_mhs.nil?
    end
    return hashrate
  end

  def estimated_daily_hashrate
    history = self.worker_histories.where(:created_at => 1.days.ago..DateTime.now)
    history.blank? ? 0 : history.average(:hash_rate_mhs)
  end

  def current_reject_rate
    workers = self.current_workers

    if not workers.blank?
      return (workers.reduce(0) {|sum, worker| sum + worker.reject_rate.to_f }.to_f / workers.size)
    end

    return 0
  end

  def current_workers
    self.workers.select {|worker| worker.active?}
  end

  def all_time_shares(worker_credits = self.worker_credits)
    worker_credits.reduce(0) { |shares, credit| shares + credit.accepted_shares.to_i }
  end

  def coin_settings
    UserCoinSetting.where(:user => self)
  end

  def address_for(coin)
    setting = self.user_coin_settings.find_by(:coin => coin)
    return setting.payout_address.strip if (!setting.nil? && !setting.payout_address.nil?)
  end

  def place_in_line
    if !self.is_enabled
      # Find all of the users who are not enabled and put them in an order
      # since we will be letting people in in order
      disabled_users = User.where(:is_enabled => false).order(:id)
      # Find where the user is at in the line
      disabled_users.each_with_index do |user, i|
        if (user.id == self.id)
          return i
        end
      end
      # Default case, for edges, yo
      return 5
    else
      # User is already enabled
      return 0
    end
  end

  def user_dashboard_info_query(user = self)
    return User.find(user.id, :include => [:workers, :worker_credits, {:payouts => {:worker_credit => :round}}, {:rounds => [:pool]}])
  end

  def gauth_enabled?
    return self.gauth_enabled == '1'
  end

  def reauthenticate(pin, password, gauth_code = nil)
    # Set up the return hash
    result = {
      :status => 'error',
      :message => 'User not logged in'
    }

    # Handle 2FA first
    if !gauth_code.nil? && self.gauth_enabled?
      if !self.validate_token_no_tmp_datetime(gauth_code)
        result['message'] = 'Incorrect 2-Factor Authentication Code'
        return result
      end
    end

    # Verify the credentials
    if pin == self.pin
      if self.valid_password?(password)
        result = {
          :status => 'success',
          :message => 'Successfully authenticated user'
        }
      else
        result['message'] = 'Incorrect password'
      end
    else
      result['message'] = 'Incorrect PIN'
    end
    return result
  end

  # This method is lifted from the 2FA source
  # It removes the precondition check for a temp datetime thing that is whack anyway
  # since we will never use this for the initial authentication, the temp datetime
  # doesn't matter to us.
  # https://github.com/AsteriskLabs/devise_google_authenticator/blob/master/lib/devise_google_authenticatable/models/google_authenticatable.rb#L31
  def validate_token_no_tmp_datetime(token)
    valid_vals = []
    valid_vals << ROTP::TOTP.new(self.get_qr).at(Time.now)
    (1..self.class.ga_timedrift).each do |cc|
      valid_vals << ROTP::TOTP.new(self.get_qr).at(Time.now.ago(30*cc))
      valid_vals << ROTP::TOTP.new(self.get_qr).at(Time.now.in(30*cc))
    end

    if valid_vals.include?(token.to_i)
      return true
    else
      return false
    end
  end

  def valid_workers
    return Worker.where(:user => self, :is_enabled => true)
  end

  def reset_pin
    UserPinResets.create!(:user => self, :code => SecureRandom.hex, :used => false)
  end

  def latest_reset_pin
    UserPinResets.where(user: self).order(:created_at).reverse_order.first
  end

  def unread_notification_count
    Notifications.where(:read => false, :user => self).count
  end

  def unread_notifications
    Notifications.where(:read => false, :user => self).reverse_order
  end

  def all_notifications
    Notifications.where(:user => self).reverse_order
  end

  def send_welcome_email
    UserMailer.send_welcome_email(self).deliver
  end
end
