# coding: utf-8
require 'uri'
require 'redis'

module Soulheart
  module Config
    

    # Accepts:
    #   1. A Redis URL String 'redis://host:port/db'
    #   2. An existing instance of Redis, Redis::Namespace, etc.
    def redis=(server)
      if server.is_a?(String)
        @redis = nil
        @redis_url = server
      else
        @redis = server
      end

      redis
    end

    def jruby?
      RUBY_ENGINE == 'jruby'
    end

    # Returns the current Redis connection. If none has been created, will
    # create a new one.
    def redis
      @redis ||= (
        url = URI(@redis_url || ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/0')
        ::Redis.new(
          host: url.host,
          port: url.port,
          db: url.path[1..-1],
          password: url.password)
      )
    end

    def base_id
      ENV['RACK_ENV'] != 'test' ? 'soulheart:' : 'soulheart_test:'
    end

    def stop_words_id
      "#{base_id}stop_list:"
    end

    def default_stop_words
      %w(vs at the)
    end

    def redis_stop_words
      return false unless redis.exists stop_words_id
      redis.lrange(stop_words_id, 0, -1) 
    end

    def stop_words
      @stop_words ||= redis_stop_words || default_stop_words
    end

    def stop_words=(arr)
      redis.expire stop_words_id, 0
      @stop_words = Array(arr).flatten
      redis.lpush stop_words_id, @stop_words
    end

    def normalizer_id
      "#{base_id}normalizer:"
    end

    def default_normalizer
      '[^\p{Word}\ ]'
    end

    def redis_normalizer
      return false unless redis.exists normalizer_id
      redis.get normalizer_id
    end

    def normalizer
      @normalizer ||= redis_normalizer || default_normalizer
    end

    def normalizer=(str)
      redis.expire normalizer_id, 0
      @normalizer = str
      redis.set normalizer_id, @normalizer
    end
  end
end
