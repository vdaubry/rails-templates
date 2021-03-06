require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module %app_name%
  class Application < Rails::Application
    config.api_only = true
    config.debug_exception_response_format = :api
    config.middleware.use Rack::Deflater #GZIP response
    config.exceptions_app = self.routes #custom response for /404 and /500
    #Set the application in french
    #config.time_zone = 'Paris'
    #config.i18n.default_locale = :fr
    
    config.generators do |g|
      g.resource_controller "lib/templates/rails/scaffold_controller/api_controller.rb"
      g.test_framework :rspec
      g.integration_tool nil
      g.view_specs false
      g.helper_specs false
      g.routing_specs false
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
      g.serializer :serializer
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

    #lograge
    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      params = event.payload[:params].reject do |k|
        ['controller', 'action'].include? k
      end

      params = params.merge(event.payload[:headers].env.select {|k| ["HTTP_X_API_KEY", "HTTP_AUTHORIZATION"].include? k })

      { "params" => params }
    end
    config.log_tags = [ lambda {|req| Time.now.to_s(:db) }, :remote_ip ]
  end
end