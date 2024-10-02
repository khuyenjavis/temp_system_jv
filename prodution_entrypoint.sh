#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
if [ -f /rails-app-production/tmp/pids/server.pid ]; then
  rm /rails-app-production/tmp/pids/server.pid
fi

bundle check || bundle install

exec "$@"
