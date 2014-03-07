module HomeHelper

  def get_new_users_in_24_hours_count
  return User.find(:all, :conditions => ["created_at between ? and ?",
         DateTime.now - 24.hours, DateTime.now]).count
  end

  def get_all_users_count
    User.count
  end

  def get_active_users_count
  	User.where(:is_enabled => true).count
  end

end
