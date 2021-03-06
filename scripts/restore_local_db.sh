#!/usr/bin/env bash
set -e

PROD="{your-app}-production"
STAGING="{your-app}-staging"
LOCAL_DB_NAME={your-app}_development

if [[ $1 == "production" ]]; then
  current=$PROD
else
  echo "To run on production DB, use ./scripts/restore_local_db.sh prod"
  current=$STAGING
fi

echo "CLOSE ALL PROGRAMS USING THE DATABASE : Ruby web server, SQL client, etc"
lsof -t -i tcp:3000 | xargs kill -9
pkill Valentina || true
pkill rails || true

echo "snapshot remote DB $current"
heroku pg:backups capture -a $current
echo "Reset DB"
bundle exec rake db:drop db:create
echo "Download DB dump from $current"
curl -o tmp/db.dump `heroku pg:backups:url -a $current`
echo "Restore DB"
pg_restore -h localhost -d $LOCAL_DB_NAME tmp/db.dump || true
echo "Restore test db"
RAILS_ENV=test bundle exec rake db:migrate