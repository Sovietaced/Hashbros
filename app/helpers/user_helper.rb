module UserHelper
  def get_user_profile_picture(user = current_user)
    # TODO
    return ''
  end

  def get_user_name(user = current_user)
    if user_signed_in?
      return user.username if not user.username.nil?
      return user.email if not user.email.nil?
      return ''
    end
  end
end
