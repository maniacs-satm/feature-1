require 'set'
require 'feature/group'

class Feature::Feature
  attr_reader :name
  attr_reader :backend
  attr_reader :groups
  attr_reader :default

  def initialize(name, backend, opts = {})
    @name = name
    @backend = backend
    @default = opts[:default].nil? ? true : opts[:default]

    groups = opts[:groups] || []
    set_groups(groups)
  end

  # Returns the members that have this feature enabled.
  # - It returns `:all` if globally enabled
  # - A list of all the members of each group
  # - `:all` if enabled by default or an empty collection otherwise.
  def members
    return :all if backend.feature_globally_enabled?(name)

    if groups.any?
      return groups.map { |group| group.members }.flatten(1).uniq
    end

    default ? :all : []
  end

  # Enable the given feature globally.
  def enable
    backend.enable(name)
  end

  # Disable the given feature globally.
  def disable
    backend.disable(name)
  end

  # Checks if the feature is enabled.
  #
  # Checks, in precedence order:
  # - It first checks if the feature is on globally.
  # - Check if the value given belongs to one of the groups
  # - Return the default value
  def enabled?(opts = {})
    return true if backend.feature_globally_enabled?(name)

    if groups.any? && !!opts[:for]
      return true if groups.any? {|g| g.member?(opts[:for]) }
    end

    default
  end

  private

  def set_groups(groups)
    @groups = Set.new

    groups.each { |name| @groups << Feature::Group.new(name, backend) }
  end
end
