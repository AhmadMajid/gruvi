#!/usr/bin/env bash
set -ex

echo "==> Checking storage directory..."
ls -la storage/ || echo "Storage directory not found!"

echo "==> Creating database if it doesn't exist..."
bundle exec rake db:create || echo "Database already exists or creation failed"

echo "==> Running database migrations..."
bundle exec rake db:migrate

echo "==> Starting Rails server..."
bundle exec rails server -b 0.0.0.0 -p $PORT
