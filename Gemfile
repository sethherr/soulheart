source 'http://rubygems.org'

group :development do
  gem 'rspec',      '~> 2.14.1'
  gem 'bundler'
  gem 'guard'
  gem 'guard-rspec', '~> 4.2.8'
  gem 'rubocop'
end

group :test do
  gem 'rack-test'
  gem 'codeclimate-test-reporter', require: nil
end

gem 'rake'
gem 'soulheart'
gem 'vegas',      '>= 0.1.0'
gem 'sinatra'
gem 'multi_json', '>= 1.11.0'

platforms :ruby do
  gem 'hiredis'
  gem 'redis', '>= 3.2.0', require: ['redis', 'redis/connection/hiredis']
end