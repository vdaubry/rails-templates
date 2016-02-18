require 'raven'

if Rails.env.production?
  Raven.configure do |config|
    config.dsn = 'https://xxxxxx@app.getsentry.com/50134'
  end
end