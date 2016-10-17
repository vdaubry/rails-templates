#!/usr/bin/env ruby

require 'dotenv'

APP="themenu-api"
PROD="#{APP}-production"
STAGING="#{APP}-staging"

Dotenv.load

system "heroku create #{PROD}"
system "git remote add production git@heroku.com:#{PROD}.git"
system "heroku addons:create heroku-postgresql:standard-0"
system "heroku addons:create papertrail:choklad"
system "heroku addons:create sentry:small29"
system "heroku addons:create newrelic:wayne"
system "heroku addons:create rediscloud:30"
system "heroku addons:create semaphore:nano"
system "heroku addons:create sendgrid:starter"
system "heroku pg:backups schedule DATABASE_URL --at '02:00 Europe/Paris'"

#heroku run rake task buildpack
system "heroku buildpacks:set https://github.com/heroku/heroku-buildpack-ruby"
system "heroku buildpacks:add https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks"
system "heroku config:set DEPLOY_TASKS='db:migrate'"
system "heroku config:set THEMENU_AWS_ACCESS_KEY=#{ENV["THEMENU_AWS_ACCESS_KEY"]}"
system "heroku config:set THEMENU_AWS_SECRET=#{ENV["THEMENU_AWS_SECRET"]}"
system "heroku config:set REDIS_URL=`heroku config:get REDISCLOUD_URL`"
system "heroku config:set MAX_THREADS=3"
system "heroku config:set WEB_CONCURRENCY=1"
system "heroku config:set RACK_ENV=production"
system "heroku config:set RAILS_ENV=production"
system "heroku config:set HOST=#{PROD}.herokuapp.com"

#Create admin user
system "heroku run rake db:seed"

# Create heroku staging env
system "heroku fork --from #{PROD} --to #{STAGING} --skip-pg"
system "heroku addons:destroy sentry:small29 -a #{PROD} --confirm #{STAGING}"
system "heroku addons:destroy semaphore:nano -a #{STAGING} --confirm #{STAGING}"
system "heroku addons:create heroku-postgresql:hobby-basic -a #{STAGING}"
system "heroku pg:wait -a #{STAGING}"
system "heroku pg:copy #{PROD}::DATABASE_URL DATABASE_URL -a #{STAGING} --confirm #{STAGING}"
system "heroku config:set HOST=#{STAGING}.herokuapp.com -a #{STAGING}"