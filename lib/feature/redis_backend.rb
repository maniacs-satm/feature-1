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

  # Defines a new group and initializes it with a set of values. Clears previous
  # values if group existed previously.
  #
  # TODO come up with a better way to avoid clashes between feature and group
  # key names.
  def new_group(name, values)
    delete_group(name)

    values.each {|value| @redis.sadd(group_key(name), value) }
  end

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

  # Checks if the given value is part of the group
  def in_group?(name, value)
    @redis.sismember(group_key(name), value)
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
