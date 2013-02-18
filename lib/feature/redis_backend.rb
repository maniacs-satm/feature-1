require 'redis/namespace'

class Feature::RedisBackend
  attr_reader :redis

  def initialize(redis_connection, opts = {})
    namespace = opts.fetch(:namespace, 'feature')
    @redis = Redis::Namespace.new(namespace, redis: redis_connection)
  end

  # Check if a feature is enabled
  def feature_globally_enabled?(feature)
    case @redis.get(feature)
    when 'enabled'
      true
    when 'disabled'
      false
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

  # Groups functionality

  # Returns all the groups
  def groups
    group_names = @redis.smembers('groups')
    group_names.map{ |name| Feature::Group.new(name, self) }
  end

  def group_members(name)
    @redis.smembers(group_key(name))
  end

  # Deletes a group.
  def clear_group(name)
    @redis.del(group_key(name))
  end

  def add_to_group(name, value)
    @redis.sadd('groups', name)
    @redis.sadd(group_key(name), value)
  end

  def remove_from_group(name, value)
    @redis.srem(group_key(name), value)
  end

  # Checks if the given value is part of the group
  def in_group?(name, value)
    @redis.sismember(group_key(name), value)
  end

  def group_key(name)
    "group:#{name}"
  end
end
