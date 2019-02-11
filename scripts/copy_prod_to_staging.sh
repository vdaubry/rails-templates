#!/usr/bin/env bash
set -e

PROD="themenu-api-production"
STAGING="themenu-api-staging"

echo "Snapshot production db"
heroku pg:backups:capture -a $PROD

echo "Restore production db in staging"
heroku pg:backups:restore `heroku pg:backups:public-url -a $PROD` DATABASE -a $STAGING

echo "Run migration"
heroku run rake db:migrate -a $STAGING