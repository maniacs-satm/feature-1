# Feature

A simple feature switching framework.

## Installation

```console
# note: not on rubygems, so doesn't work yet...
$ gem install feature
```

## Usage

It's written pretty generically, so we should be able to do quite a lot with
it. Right now you can just turn features on and off globally, and the only
included backend is for Redis.

A Feature can be enabled globally or through groups. Group settings only apply
when the feature is turned off globally. In other words, if the feature is
enabled globally then the group settings are ignored.

### Defining Groups and Features

Modify `config/initializers/feature.rb`, and add a call to `feature`, passing
in the name of the feature as a symbol, and what you want the default to be.
The default will be used when the feature hasn't been explicitly enabled or
disabled.

```ruby
Feature.configure do
  backend Feature::RedisBackend.new(...)

  group :employees, values: %w(id1 id4 id7)

  group :beta_users, values: %w(id8 id10 id15)

  feature :sepa_payments, default: false, groups: %w(beta_users employees)
end
```

### Checking if a Feature is Enabled

Call `Feature.enabled?` with the name of the feature:

```ruby
Feature.enabled? :sepa_payments  # => false
```

or to check if a feature is enabled for given value(2) (gets checked against
the defined groups for the feature):

```ruby
Feature.enabled? :sepa_payments, for: current_user.id
# True if enabled for id-1 AND id-2
Feature.enabled? :sepa_payments, for: ["id-1", "id-2"]
```

Check if a feature is enabled for any in a given array

```ruby
# True if enabled for id-1 or id-2
Feature.enabled?(:sepa_payments, for_any: ["id-1", "id-2"])
```

NB. If more than one `for*` option is passed, the order of preference is
`for`, then `for_any`.

### Enabling and Disabling Features Globally

Just call `enable` or `disable` with the name of the feature.

```ruby
Feature.enable :sepa_payments
Feature.enabled? :sepa_payments  # => true
Feature.disable :sepa_payments
Feature.enabled? :sepa_payments  # => false
```
### Changing Groups membership during runtime

It is possible to change a group membership state during runtime.

Examples from a Ruby irb session:

```ruby
# Add user to the 'employees' group
Feature.add_to_group(:employees, user.id)

# Remove user from the 'employees' group
Feature.remove_from_group(:employees, user.id)
```
