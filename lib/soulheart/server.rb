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
      MultiJson.encode(matches:  matches)
    end

    get '/categories' do
      MultiJson.encode(categories: Base.new.sorted_category_array)
    end

    get '/info' do
      info = Soulheart::Base.new.redis.info
      MultiJson.encode({
        soulheart_version: Soulheart::VERSION,
        current_time: Time.now.utc.strftime('%H:%M:%S UTC'),
        redis_used_memory: info['used_memory_human'],
        stop_words: Soulheart.stop_words,
        normalizer: Soulheart.normalizer,
      })
    end

    not_found do
      content_type 'application/json', charset: 'utf-8'
      MultiJson.encode(error: 'not found')
    end
  end
end
