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

  def members
    # TODO return all members in this feature
  end

  def enable
  end

  def disable
  end

  def enabled?(opts = {})
  end

    default
  end

  private

  def set_groups(groups)
    @groups = Set.new

    groups.each { |name| @groups << Feature::Group.new(name, backend) }
  end
end
