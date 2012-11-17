require 'redis/namespace'

class Feature::RedisBackend
  attr_reader :redis

  def initialize(redis_connection, opts = {})
    namespace = opts.fetch(:namespace, 'feature')
    @redis = Redis::Namespace.new(namespace, redis: redis_connection)
  end

  # Check if a feature is globally enabled
  def enabled?(feature, default = true)
    case @redis.get(feature)
    when 'enabled'
      true
    when 'disabled'
      false
    else
      default
    end
  end

  # Globally enable a feature
  def enable(feature)
    @redis.set(feature, 'enabled')
  end

  # Globally disable a feature
  def disable(feature)
    @redis.set(feature, 'disabled')
  end

  def reset!
    # TODO use of KEYS command is recommended only for debugging. Refactor.
    keys = @redis.keys
    @redis.del(*keys) unless keys.empty?
  end
end

