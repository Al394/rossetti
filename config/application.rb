require_relative 'boot'

require 'rails/all'
require 'rmagick'
require 'net/ssh'
require 'net/sftp'
require 'net/http'
require 'tiny_tds'
require 'uri'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rossetti
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.time_zone = 'Rome'

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    config.i18n.available_locales = [:it]
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :it
    config.i18n.fallbacks = true

    config.active_job.queue_adapter = :sidekiq
    config.active_storage.queues = Hash.new(:rossetti)
  end
end
