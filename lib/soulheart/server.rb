require 'sinatra/base'
require 'soulheart'

module Soulheart
  class Server < Sinatra::Base
    include Helpers

    before do
      content_type 'application/json', charset: 'utf-8'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, GET, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

    get '/' do
      matches = Matcher.new(params).matches
      {matches:  matches}.to_json
    end

    get '/categories' do
      {categories: Base.new.sorted_category_array}.to_json
    end

    get '/info' do
      info = Soulheart::Base.new.redis.info
      {
        soulheart_version: Soulheart::VERSION,
        current_time: Time.now.utc.strftime('%H:%M:%S UTC'),
        redis_used_memory: info['used_memory_human'],
        stop_words: Soulheart.stop_words,
        normalizer: Soulheart.normalizer,
      }.to_json
    end

    not_found do
      content_type 'application/json', charset: 'utf-8'
      {error: 'not found'}.to_json
    end
  end
end
