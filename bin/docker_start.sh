#!/bin/sh

if [ -f tmp/pids/server.pid ]; then
    rm tmp/pids/server.pid
fi

bundle check || bundle install

bundle exec rails db:migrate

if [ "$RAILS_ENV" = "production" -o "$RAILS_ENV" = "staging" ]; then
    mkdir -p tmp/pids
    rake assets:precompile
    RAILS_ENV=$RAILS_ENV bundle exec puma -C config/puma.rb
else
    bundle exec rails db:seed
    bundle exec rails s -b 0.0.0.0 -p $RAILS_PORT
fi
