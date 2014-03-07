source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>4.0.0'

# AWS!
gem "aws-sdk", "= 1.6.2" # Bug https://github.com/thoughtbot/paperclip/issues/751
gem 'aws-ses', '~> 0.4.4', require: 'aws/ses'

# Use Devise for authentication
gem 'devise', '3.2.2'
# Devise/Google 2FA
gem 'devise_google_authenticator', '0.3.8'

# Authorization
gem "cancan"

# Use Rails admin for a quick backend
gem 'rails_admin', :git => 'https://github.com/sferik/rails_admin.git'

# Use whenever for cron jobs!
gem 'whenever', :require => false

# Pagination
gem 'kaminari'

# API bundle
gem 'grape'
gem 'grape-active_model_serializers'
gem 'grape-rails-cache'

# FONT AWESOME
gem "font-awesome-rails"

# Time differences
gem 'time_diff'

# Relative Time
gem 'rails-timeago', '~> 2.0'

# Enums
gem 'enumerize'

# Stats
gem 'moving_average'

# Cryptsy
gem 'cryptsy-api'

# REST CLIENT
gem 'httparty'

# SEO!!!
gem "headliner", "~> 0.1.3"
gem "metamagic"
gem 'friendly_id', :git => 'https://github.com/norman/friendly_id.git'
gem "dynamic_sitemaps", "2.0.0.beta2"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use postgresql
gem 'pg', group: :production

# Monitoring
gem 'newrelic_rpm', group: :production
gem 'newrelic-rake', group: :production

# Use unicorn as the app server
gem 'puma', group: :production
gem 'foreman', group: :production

# Memcached
gem 'dalli', group: :production

# Use Capistrano for deployment
gem 'capistrano', group: :development
gem 'rvm-capistrano', group: :development

# Wow, much blog
gem "monologue", :github => 'jipiboily/monologue', :branch => 'master'

# Let's do some charting
gem "highcharts-rails", "~> 3.0.0"
gem 'highstock-rails'

# Use sqlite3 as the database for Active Record in development
group :development do
  gem 'sqlite3'
end
