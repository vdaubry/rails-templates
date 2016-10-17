#!/usr/bin/env ruby

require 'dotenv'

APP="themenu-api"

Dotenv.load

system "git remote add production git@heroku.com:#{APP}.git"
system "heroku addons:create heroku-postgresql:standard-0"
system "heroku addons:create papertrail:choklad"
system "heroku addons:create sentry:small29"
system "heroku addons:create newrelic:wayne"
system "heroku addons:create rediscloud:30"
system "heroku pg:backups schedule DATABASE_URL --at '02:00 Europe/Paris' -a #{APP}"

#heroku run rake task buildpack
system "heroku buildpacks:set https://github.com/heroku/heroku-buildpack-ruby"
system "heroku buildpacks:add https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks"
system "heroku config:set DEPLOY_TASKS='db:migrate'"
system "heroku config:set THEMENU_AWS_ACCESS_KEY=#{ENV["THEMENU_AWS_ACCESS_KEY"]}"
system "heroku config:set THEMENU_AWS_SECRET=#{ENV["THEMENU_AWS_SECRET"]}"
system "heroku config:set REDIS_URL=`heroku config:get REDISCLOUD_URL`"
system "heroku config:set MAX_THREADS=3"
system "heroku config:set WEB_CONCURRENCY=1"