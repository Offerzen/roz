web: bundle exec rails server -p $PORT
worker: bundle exec sidekiq -q default -C config/sidekiq.yml
release: rails db:migrate
