# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'dotenv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HealthManagement
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.time_zone = 'Asia/Tokyo'
    # config.i18n.default_locale = :en
    Dotenv::Railtie.load
    config.autoload_paths += %W[#{config.root}/lib/request]
    config.autoload_paths << Rails.root.join('lib', 'middlewares')
    config.autoload_paths << Rails.root.join('lib', 'log_wrappers')
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
