#!/usr/bin/env bash
set -e

echo "Creating database if it doesn't exist..."
bundle exec rake db:create

echo "Running database migrations..."
bundle exec rake db:migrate

echo "Starting Rails server..."
bundle exec rails server -b 0.0.0.0 -p $PORT
