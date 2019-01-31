require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Raven.configure do |config|
  config.dsn = 'https://25094bb30eb243aea8ba76ae78b49ace:96a60eb19ec44a3d8f53f0d298ccd961@sentry.io/1384365'
  config.environments = %w[ production ]
end

module Employment 
  class Application < Rails::Application
    config.load_defaults 5.2

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    binding.pry

    config.api_only = true

    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')
  end
end
