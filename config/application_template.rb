require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module %app_name%
  class Application < Rails::Application
    #Set the application in french
    #config.time_zone = 'Paris'
    #config.i18n.default_locale = :fr
    
    config.generators do |g|
      g.test_framework :rspec
      g.view_specs false
      g.helper_specs false
      g.fixture_replacement :factory_girl
      g.factory_girl dir: 'spec/factories'
    end

    config.active_job.queue_adapter = :sidekiq

    Rails.application.routes.default_url_options[:host] = ENV["HOST"]
    
    ActionMailer::Base.smtp_settings = {
        :user_name => ENV['SENDGRID_USERNAME'],
        :password => ENV['SENDGRID_PASSWORD'],
        :domain => ENV['HOST'],
        :address => 'smtp.sendgrid.net',
        :port => 587,
        :authentication => :plain,
        :enable_starttls_auto => true
    }
    config.action_mailer.default_url_options = { host: ENV['HOST'] }
    config.action_mailer.perform_deliveries = true
    config.action_mailer.delivery_method = :smtp
    config.asset_host = "http://#{ENV['HOST']}"

    #lograge
    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      params = event.payload[:params].reject do |k|
        ['controller', 'action'].include? k
      end

      { "params" => params }
    end
    config.log_tags = [ lambda {|req| Time.now.to_s(:db) }, :remote_ip ]
  end
end