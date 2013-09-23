require File.expand_path('../lib/feature/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'feature'
  gem.version = Feature::VERSION.dup
  gem.authors = ['Harry Marr']
  gem.email = ['developers@gocardless.com']
  gem.summary = 'A basic feature switching framework'
  gem.homepage = 'https://github.com/gocardless/feature'

  gem.add_dependency 'redis-namespace', '~> 1.2'
  gem.add_dependency 'sinatra', '~> 1.3.2'
  gem.add_dependency 'rack-flash3', '~> 1.0.3'

  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'mocha', '~> 0.12'

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- spec/*`.split("\n")
end
