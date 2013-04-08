module Feature
  autoload :Config, 'feature/config'
  autoload :RedisBackend, 'feature/redis_backend'
  autoload :Feature, 'feature/feature'
  autoload :Dashboard, 'feature/dashboard'

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

  # Return an array of group member IDs
  def self.get_group_members(group)
    backend.get_group_members(group)
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
    config = Config.new(block)
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

def Feature(name)
  Feature.check_feature_defined(name)
  Feature::Feature.new(name, Feature.features[name])
end

