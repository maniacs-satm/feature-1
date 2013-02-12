module Feature
  autoload :Config, 'feature/config'
  autoload :RedisBackend, 'feature/redis_backend'

  # Check if the given feature is enabled. If it hasn't been set explicitly,
  # it will fall back to the default provided in the config. If no default was
  # provided, it will return true.
  def self.enabled?(feature_name, opts= {})
    check_feature_defined(feature_name)

    feature_opts = @features[feature_name]
    feature_opts = feature_opts.merge(value: opts[:for]) if opts[:for]
    backend.enabled?(feature_name, feature_opts)
  end

  # Enable the given feature globally.
  def self.enable(feature_name)
    check_feature_defined(feature_name)
    backend.enable(feature_name)
  end

  # Disable the given feature globally.
  def self.disable(feature_name)
    check_feature_defined(feature_name)
    backend.disable(feature_name)
  end

  # Ads a value to be part of a group. This is useful at runtime to avoid having
  # to restart the application just to enable / disable a feature for a given
  # user.
  #
  # Pass an instance of String that the backend will store
  #
  # Note that groups are overriden at application restart so make sure to edit
  # your config if you want the changes to be permanent.
  def self.add_to_group(name, value)
    backend.add_to_group(name, value)
  end

  # Removes a value from a group. This is useful at runtime to avoid having
  # to restart the application just to enable / disable a feature for a given
  # user.
  #
  # Pass an instance of String that the backend will delete from the group
  #
  # Note that groups are overriden at application restart so make sure to edit
  # your config if you want the changes to be permanent.
  def self.remove_from_group(name, value)
    backend.remove_from_group(name, value)
  end

  # Pass a block to configure, calling 'feature' for each feature you want to
  # define.
  #
  # Pass an instance of a backend (e.g. RedisBackend to backend)
  #
  # Examples
  #
  #   Feature.configure do
  #     backend Feature::RedisBackend($redis)
  #     feature :postcode_lookup, default: :off
  #   end
  #
  def self.configure(&block)
    config = Feature::Config.new(block)
    @features ||= {}
    @features.merge!(config.features)
    @backend = config.backend_obj unless config.backend_obj.nil?
  end

  # Check that the given feature has been defined, raising an exception if not.
  def self.check_feature_defined(feature_name)
    unless @features.include?(feature_name)
      raise "Feature '#{feature_name}' is not defined"
    end
  end

  def self.backend
    raise "No backend specified" if @backend.nil?
    @backend
  end

  def self.features
    @features
  end
end

