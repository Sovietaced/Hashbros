class UserMailer < ActionMailer::Base
  default from: 'no-reply@hashbros.co.in'

  def accepted_email(user)
  	@user = user
  	@url = 'http://hashbros.co.in/users/sign_in'
  	mail(to: @user.email, subject: 'Your HashBros account has been approved!')
  end

  def pin_changed(user)
    @user = user
    @login_url = 'http://hashbros.co.in/users/sign_in'
    @pin_url = 'http://hashbros.co.in/users/settings/security/pin'
    @edit_user_url = 'http://hashbros.co.in/users/edit'
    mail(to: @user.email, subject: 'Your HashBros PIN number was changed')
  end

  def payout_address_changed(user, coin)
  	@user = user
    @coin = coin
    @login_url = 'http://hashbros.co.in/users/sign_in'
  	@coin_settings_url = 'http://hashbros.co.in/settings'
    @edit_user_url = 'http://hashbros.co.in/users/edit'
  	mail(to: @user.email, subject: 'The payout address for ' + @coin.name + ' on your HashBros account has been changed')
  end

  def redemption_requested(user)
    @user = user
    @login_url = 'http://hashbros.co.in/users/sign_in'
    @security_url = 'http://hashbros.co.in/users/settings/security'
    @contact_url = 'http://hashbros.co.in/contact'
    mail(to: @user.email, subject: 'A Redemption Has Been Requested on your HashBros Account')
  end

  def reset_pin_instructions(user, user_pin_reset)
    @user = user
    @login_url = 'http://hashbros.co.in/users/sign_in'
    @security_url = 'http://hashbros.co.in/users/settings/security'
    @reset_url = 'http://hashbros.co.in/users/settings/security/pin/reset/' + user_pin_reset.code
    mail(to: @user.email, subject: 'Your HashBros PIN Reset Instructions')
  end

  def send_welcome_email(user)
    @user = user
    @login_url = 'https://hashbros.co.in/users/sign_in'
    @getting_started_url = 'https://hashbros.co.in/getting-started'
    @metrics_url = 'https://hashbros.co.in/metrics'
    mail(to: @user.email, subject: 'Welcome to HashBros!')
  end
end
