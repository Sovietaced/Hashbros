require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Hashbros
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

     # Add the fonts path
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # For our modules in the model subfolders
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]
    config.autoload_paths += %W(#{config.root}/lib)
    # Precompile additional assets
    config.assets.precompile += %w( .js .css .svg .eot .woff .ttf)

    config.secret_key_base = 'k-=xiq9d&$%2xkt43ju_gnb8zu@_uucft8$!5%$gfe_(6cc+22'

    # Route all of our exceptions through our own routes file
    # so that we can retain the sexy stylings
    if Rails.env.production?
      config.exceptions_app = self.routes
    end

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
