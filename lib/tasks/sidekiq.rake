namespace :sidekiq do
  desc 'Start sidekiq'
  task(:start) do
    config = Rails.root.join('config', 'sidekiq.yml')
    env    = ENV['RAILS_ENV'] || 'development'
    `bundle exec sidekiq -C #{config} -e #{env}`
  end

  desc 'stop sidekiq'
  task(:start) do
    pid = Rails.root.join('tmp/pids', 'sidekiq.pid')
    env = ENV['RAILS_ENV'] || 'development'
    `bundle exec sidekiqctl stop #{pid} 60 -e #{env}`
  end
end
