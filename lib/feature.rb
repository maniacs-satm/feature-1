module Feature
  autoload :Config, 'feature/config'
  autoload :RedisBackend, 'feature/redis_backend'

  # Check if the given feature is enabled. If it hasn't been set explicitly,
  # it will fall back to the default provided in the config. If no default was
  # provided, it will return true.
  def self.enabled?(feature_name)
    check_feature_defined(feature_name)
    feature_opts = @features[feature_name]
    backend.enabled?(feature_name, feature_opts[:default])
  end

  # Enable the given feature.
  def self.enable(feature_name)
    check_feature_defined(feature_name)
    backend.enable(feature_name)
  end

  # Disable the given feature.
  def self.disable(feature_name)
    check_feature_defined(feature_name)
    backend.disable(feature_name)
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

