# config/initializers/sidekiq.rb

require 'sidekiq'
require 'sidekiq-cron'
require 'sidekiq/cron/web' # Ajoutez cette ligne

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end

# Configuration de Sidekiq-Cron
Sidekiq::Cron::Job.load_from_hash YAML.load_file(Rails.root.join('config', 'schedule.yml'))
