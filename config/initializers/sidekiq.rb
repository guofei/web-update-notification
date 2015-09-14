redis_conn = proc do
  redis = Redis.new(url: Rails.application.secrets.sidekiq_redis)
  Redis::Namespace.new(:wn, redis: redis)
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 5, &redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 25, &redis_conn)
end
