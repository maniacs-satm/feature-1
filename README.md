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

### Defining a Features

Modify `config/initializers/feature.rb`, and add a call to `feature`, passing
in the name of the feature as a symbol, and what you want the default to be.
The default will be used when the feature hasn't been explicitly enabled or
disabled.

```ruby
Feature.configure do
  backend Feature::RedisBackend.new(...)

  feature :sepa_payments, default: false
end
```

### Checking if a Feature is Enabled

Call `Feature.enabled?` with the name of the feature:

```ruby
Feature.enabled? :sepa_payments  # => false
```

### Enabling and Disabling Features

Just call `enable` or `disable` with the name of the feature.

```ruby
Feature.enable :sepa_payments
Feature.enabled? :sepa_payments  # => true
Feature.disable :sepa_payments
Feature.enabled? :sepa_payments  # => false
```

