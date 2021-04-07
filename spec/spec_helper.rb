if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end
require 'rack/test'
require 'rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'soulheart'
require 'soulheart/server'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app
    Soulheart::Server
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include RSpecMixin
end

def store_terms_fixture
  items = []
  file = File.read('spec/fixtures/multiple_categories.json')
  file.each_line { |l| items << JSON.parse(l) }
  loader = Soulheart::Loader.new
  loader.clear(true)
  loader.load(items)
end
