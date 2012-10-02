require 'mocha_standalone'
require 'redis'
require 'feature'

$redis = Redis.new

RSpec.configure do |config|
  config.mock_with :mocha
end

