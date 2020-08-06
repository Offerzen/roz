require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDISTOGO_URL'], size: 9 }
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file('config/sidekiq_scheduler.yml')
    Sidekiq::Scheduler.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDISTOGO_URL'], size: 1 }
end
