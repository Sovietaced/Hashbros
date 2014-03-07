class ApplicationController < ActionController::Base
  include NotificationsHelper, ApplicationHelper

    rescue_from CanCan::AccessDenied do |exception|
      puts exception.action # => :read
      puts exception.subject # => Article
      if current_user
        if not current_user.enabled?
          redirect_to main_app.root_url, :alert => "Not so fast there cowboy. You will be notified via email once your account is admitted."
        else
          redirect_to main_app.root_url, :alert => exception.message
        end
      end
    end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Hack fix for : https://github.com/ryanb/cancan/issues/835
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  # Some gay shit for devise to allow updating of stuff
  before_filter :configure_permitted_parameters, if: :devise_controller?

   protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :password, :password_confirmation, :email, :pin) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :password, :password_confirmation, :email, :pin, :current_password) }
  end
end
