# -*- encoding: utf-8 -*-
require File.expand_path('../lib/soulheart/version', __FILE__)

Gem::Specification.new do |gem|
  gem.version       = Soulheart::VERSION
  gem.authors       = ['Seth Herr']
  gem.email         = ['seth.william.herr@gmail.com']
  gem.description   = gem.summary = 'Simple, fast autocomplete server for Ruby and Rails'
  gem.homepage      = 'https://github.com/sethherr/soulheart'
  gem.license       = 'MIT'
  gem.executables   = ['soulheart', 'soulheart-web']
  gem.files         = `git ls-files README.md Rakefile LICENSE.md lib bin`.split("\n")
  gem.name          = 'soulheart'
  gem.require_paths = ['lib']
  gem.add_dependency 'hiredis', '~> 0.4.5'
  gem.add_dependency 'redis', '>= 3.0.6'
  gem.add_dependency 'vegas', '>= 0.1.0'
  gem.add_dependency 'json'
  gem.add_dependency 'sinatra'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
end
