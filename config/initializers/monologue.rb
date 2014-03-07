Monologue.config do |config|
  config.site_name = "HashBros.co.in Blog"
  config.site_subtitle = "Brogrammin wisdom"
  config.site_url = "http://HashBros.co.in"

  config.meta_description = "Development blog regarding HashBros.co.in"
  config.meta_keyword = "rails, programming, ruby, alt-coin, bitcoin, litecoin"

  config.admin_force_ssl = false
  config.posts_per_page = 5

  config.disqus_shortname = "hashbroscoin"

  # LOCALE
  config.twitter_locale = "en" # "fr"
  config.facebook_like_locale = "en_US" # "fr_CA"
  config.google_plusone_locale = "en"

  config.layout               = "layouts/application"

  # ANALYTICS
  # config.gauge_analytics_site_id = "YOUR COGE FROM GAUG.ES"
  # config.google_analytics_id = "YOUR GA CODE"

  config.sidebar = ["latest_posts", "categories", "tag_cloud"]


  #SOCIAL
  config.twitter_username = "HashBrosPool"
  #config.facebook_url = "https://www.facebook.com/jipiboily"
  #config.facebook_logo = 'logo.png'
  #config.google_plus_account_url = "https://plus.google.com/u/1/115273180419164295760/posts"
  #config.linkedin_url = "http://www.linkedin.com/in/jipiboily"
  #config.github_username = "jipiboily"
  config.show_rss_icon = true

end
