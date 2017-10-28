#!/usr/bin/env ruby

require 'dotenv'

APP="themenu-api"
PROD="#{APP}-prod"
STAGING="#{APP}-staging"

Dotenv.load

system "heroku create #{PROD}"
system "git remote add production git@heroku.com:#{PROD}.git"
system "heroku addons:create heroku-postgresql:standard-0 -a #{PROD}"
system "heroku addons:create papertrail:choklad -a #{PROD}"
system "heroku addons:create sentry:f1 -a #{PROD}"
system "heroku addons:create newrelic:wayne -a #{PROD}"
system "heroku addons:create rediscloud:30 -a #{PROD}"
system "heroku addons:create semaphore:nano -a #{PROD}"
system "heroku addons:create sendgrid:starter -a #{PROD}"
system "heroku pg:backups schedule DATABASE_URL --at '02:00 Europe/Paris' -a #{PROD}"

#heroku run rake task buildpack
system "heroku buildpacks:set https://github.com/heroku/heroku-buildpack-ruby -a #{PROD}"
system "heroku buildpacks:add https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks -a #{PROD}"
system "heroku config:set DEPLOY_TASKS='db:migrate' -a #{PROD}"
system "heroku config:set THEMENU_AWS_ACCESS_KEY=#{ENV["THEMENU_AWS_ACCESS_KEY"]} -a #{PROD}"
system "heroku config:set THEMENU_AWS_SECRET=#{ENV["THEMENU_AWS_SECRET"]} -a #{PROD}"
system "heroku config:set REDIS_URL=`heroku config:get REDISCLOUD_URL` -a #{PROD}"
system "heroku config:set MAX_THREADS=3 -a #{PROD}"
system "heroku config:set WEB_CONCURRENCY=1 -a #{PROD}"
system "heroku config:set RACK_ENV=production -a #{PROD}"
system "heroku config:set RAILS_ENV=production -a #{PROD}"
system "heroku config:set HOST=#{PROD}.herokuapp.com -a #{PROD}"
system "heroku labs:enable runtime-dyno-metadata"

#Push code to Heroku
system "git push production master"

#Create admin user
system "heroku run rake db:seed -a #{PROD}"

# Create heroku staging env
system "heroku fork --from #{PROD} --to #{STAGING} --skip-pg"
system "heroku addons:destroy sentry:small29 -a #{STAGING} --confirm #{STAGING}"
system "heroku addons:destroy semaphore:nano -a #{STAGING} --confirm #{STAGING}"
system "heroku addons:create heroku-postgresql:hobby-basic -a #{STAGING}"
system "heroku pg:wait -a #{STAGING}"
system "heroku pg:copy #{PROD}::DATABASE_URL DATABASE_URL -a #{STAGING} --confirm #{STAGING}"
system "heroku config:set HOST=#{STAGING}.herokuapp.com -a #{STAGING}"