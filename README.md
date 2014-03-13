# Feature

A group based feature switching framework.

## Installation

```console
$ gem install feature
```

## Usage

Feature groups and members are stored in a backend. Right now the only included backend is for Redis.

A Feature can be enabled globally or through groups. Group settings only apply
when the feature is turned off globally. In other words, if the feature is
enabled globally then the group settings are ignored.

### Defining Groups and Features

In Rails, modify `config/initializers/feature.rb`, and add a call to
`feature`, passing in the name of the feature as a symbol, and what you want 
the default to be. The default will be used when the feature hasn't been 
explicitly enabled or disabled.

```ruby
Feature.configure do
  backend Feature::RedisBackend.new(...)

  feature :v2_design, default: false, groups: %w(beta_users employees)
end
```

### Checking if a Feature is Enabled

Calling `Feature(:feature_name)` will return a `Feature instance`. This can be 
interrogated for its current state.

```ruby
Feature(:v2_design).enabled?   # => false
```

Check if a feature is enabled for a given group member (gets checked against 
the defined groups for the feature):

```ruby
Feature(:v2_design).enabled_for?(current_user.id)
```

Check if a feature is enabled for ALL given group members:

```ruby
# True if enabled for id-1 AND id-2
Feature(:v2_design).enabled_for_all?(["id-1", "id-2"])
```

Check if a feature is enabled for ANY in a given array

```ruby
# True if enabled for id-1 or id-2
Feature(:v2_design).enabled_for_any?(["id-1", "id-2"])
```

### Enabling and Disabling Features Globally

Just call `enable` or `disable` on a `Feature`.

```ruby
Feature(:v2_design).enable
Feature(:v2_design).enabled?  # => true
Feature(:v2_design).disable
Feature(:v2_design).enabled?  # => false
```

### Changing Groups membership at runtime

It is possible to change a group membership at during runtime.

Examples from a Ruby irb session:

```ruby
# Add user to the 'employees' group
Feature.add_to_group(:employees, user.id)

# Remove user from the 'employees' group
Feature.remove_from_group(:employees, user.id)
```

## Dashboard

The dashboard allows features to be globally enabled / disabled and for
members to be added and removed from groups.

![Feature dashboard](http://gc-misc.s3.amazonaws.com/images/feature-dashboard.png)

To mount it in your Rails 3 app, add the following to your `routes.rb`

```ruby
mount Feature::Dashboard, at: '/path/to/dashboard'
```
