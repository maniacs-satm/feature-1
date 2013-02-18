class Feature::Group
  attr_reader :name
  attr_reader :backend

  def initialize(name, backend)
    @name = name
    @backend = backend
  end

  def members
    backend.group_members(name)
  end

  def member?(value)
    backend.in_group?(name, value)
  end

  def add(value)
    backend.add_to_group(name, value)
  end

  def remove(value)
    backend.remove_from_group(name, value)
  end

  def clear
    backend.clear_group(name)
  end
end
