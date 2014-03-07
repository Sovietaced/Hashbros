module ModelHelper
  def self.determine_group_by_syntax_for_date(table_name, column_name)
    if Rails.env == "development"
      return "strftime('%Y-%m-%d', " + table_name + "." + column_name + ")"
    else
      return table_name + "." + column_name + "::date"
    end
  end
end
