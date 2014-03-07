class WorkerSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :username, :is_enabled, :hash_rate_mhs, :difficulty, :created_at, :updated_at, :is_active, :is_profit_switch, :pool

  def is_active
  	object.active?
  end

  def pool
  	object.last_pool.id if !object.last_pool.nil? else nil
  end

  def is_profit_switch
  	object.profit_switch?
  end

end
