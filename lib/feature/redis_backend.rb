require 'redis/namespace'

class Feature::RedisBackend
  attr_reader :redis

  def initialize(redis_connection, opts = {})
    namespace = opts.fetch(:namespace, 'feature')
    @redis = Redis::Namespace.new(namespace, redis: redis_connection)
  end

  # Check if a feature is enabled. A feature enabled globally takes precedence.
  # If the feature has groups configured and is not enabled globally then group
  # membership will be checked.
  def enabled?(feature, opts)
    global_setting = check_global_value(feature, default: opts[:default])
    groups = opts.fetch(:groups, [])

    # Return the global setting if its set to true, or if the there are no
    # groups configured for the feature.
    return global_setting if global_setting || groups.empty?

    if opts[:for_any]
      return groups.any? { |group| any_in_group?(group, opts[:value]) }
    end

    groups.any? { |group| in_group?(group, opts[:value]) }
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

  # Deletes a group.
  def delete_group(name)
    @redis.del(group_key(name))
  end

  def add_to_group(name, value)
    @redis.sadd(group_key(name), value)
  end

  def remove_from_group(name, value)
    @redis.srem(group_key(name), value)
  end

  # Checks if all of the given values are part of the group, accepts a string
  # or array for value(s)
  def in_group?(name, values)
    values = [values] unless values.is_a?(Array)
    values.all? { |value| @redis.sismember(group_key(name), value) }
  end

  # Checks if any of the given values are part of the group
  def any_in_group?(name, values)
    values = [values] unless values.is_a?(Array)
    values.any? { |value| @redis.sismember(group_key(name), value) }
  end

  def group_key(name)
    "group:#{name}"
  end

  private

  def check_global_value(feature, opts)
    default = opts[:default]

    case @redis.get(feature)
    when 'enabled'
      true
    when 'disabled'
      false
    else
      default
    end
  end
end
