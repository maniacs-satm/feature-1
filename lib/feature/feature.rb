require 'feature'

module Feature
  class Feature
    def initialize(name, options)
      @name = name
      @options = options
    end

    # Check if the given feature is enabled. If it hasn't been set explicitly,
    # it will fall back to the default provided in the config. If no default
    # was provided, it will return true.
    def enabled?
      #check_feature_defined(feature_name)
      backend.enabled?(@name, @options)
    end

    # Check if the feature is enabled for a specific id.
    def enabled_for?(id)
      if id.is_a?(Enumerable)
        raise ArgumentError, "expected an id, got an enumerable"
      end
      backend.enabled?(@name, @options.merge(:for => id))
    end

    # Check if the feature is enabled for all of a given group of ids.
    def enabled_for_all?(ids)
      unless ids.is_a?(Enumerable)
        raise ArgumentError, "expected enumerable, got a #{ids.class}"
      end
      backend.enabled?(@name, @options.merge(for_all: ids))
    end

    # Check if the feature is enabled for any of a given group of ids.
    def enabled_for_any?(ids)
      unless ids.is_a?(Enumerable)
        raise ArgumentError, "expected enumerable, got a #{ids.class}"
      end
      backend.enabled?(@name, @options.merge(for_any: ids))
    end

    # Enable the given feature globally.
    def enable
      backend.enable(@name)
    end

    # Disable the given feature globally.
    def disable
      backend.disable(@name)
    end

    def backend
      ::Feature.backend
    end
  end
end
