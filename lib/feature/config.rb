require 'set'

# Class for the Feature configuration DSL. Methods defined here are
# available within the block passed to Feature.configure
class Feature::Config
  attr_reader :features
  attr_reader :groups
  attr_reader :backend_obj

  def initialize(block = nil)
    @features = {}
    @groups = Set.new
    instance_eval &block unless block.nil?
  end

  # Config DSL method for defining a new feature
  def feature(name, opts = {})
    raise "Feature '#{name}' already exists" if @features.include?(name)
    opts[:default] = true unless opts.include?(:default)
    @features[name] = opts
  end

  def backend(backend)
    @backend_obj = backend
  end
end
