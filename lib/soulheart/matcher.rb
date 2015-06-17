module Soulheart

  class Matcher < Base
    def initialize(params={})
      @opts = self.class.default_params_hash.merge params
      clean_opts
    end

    attr_accessor :opts

    def self.default_params_hash
      {
        'page' => 1,
        'per_page' => 5,
        'categories' => [],
        'query' => '',
        'cache' => true
      }
    end

    def clean_opts
      unless @opts['categories'] == '' || @opts['categories'] == []
        @opts['categories'] = @opts['categories'].split(/,|\+/) unless @opts['categories'].kind_of?(Array)
        @opts['categories'] = @opts['categories'].map{ |s| normalize(s) }.uniq.sort
        @opts['categories'] = [] if @opts['categories'].length == redis.scard(categories_id)
      end
      @opts['query'] = normalize(@opts['query']).split(' ') unless @opts['query'].kind_of?(Array)
      # .reject{ |i| i && i.length > 0 } .split(' ').reject{  Soulmate.stop_words.include?(w) }
      @opts
    end

    def categories_string
      @opts['categories'].empty? ? 'all' : @opts['categories'].join('')
    end

    def category_id_from_opts
      category_id(categories_string)
    end

    def cache_id_from_opts
      "#{cache_id(categories_string)}#{@opts['query'].join(':')}"
    end

    def interkeys_from_opts(cid)
      # If there isn't a query, we use a special key in redis
      @opts['query'].empty? ? [no_query_id(cid)] : @opts['query'].map { |w| "#{cid}#{w}" }
    end

    def matches
      cachekey = cache_id_from_opts
      cid = category_id_from_opts

      if !@opts['cache'] || !redis.exists(cachekey) || redis.exists(cachekey) == 0
        interkeys = interkeys_from_opts(cid)
        redis.zinterstore(cachekey, interkeys)
        redis.expire(cachekey, cache_length) # cache_length is set in base.rb
      end
      offset = (@opts['page'].to_i - 1) * @opts['per_page'].to_i
      limit = @opts['per_page'].to_i + offset - 1

      limit = 0 if limit < 0
      ids = redis.zrevrange(cachekey, offset, limit) # Using 'ids', even though keys are now terms
      if ids.size > 0
        results = redis.hmget(results_hashes_id, *ids)
        results = results.reject{ |r| r.nil? } # handle cached results for ids which have since been deleted
        results.map { |r| MultiJson.decode(r) }
      else
        []
      end      
    end

  end
end