module Soulheart
  class Matcher < Base
    def initialize(params = {})
      set_clean_opts(params)
    end

    attr_accessor :opts

    def self.default_params_hash
      {
        'page' => 1,
        'per_page' => 5,
        'categories' => [],
        'q' => '', # Query
        'cache' => true
      }
    end

    def sort_categories(categories)
      return [] if categories.empty?
      categories = categories.split(/,|\+/) unless categories.is_a?(Array)
      categories = categories.map { |s| normalize(s) }.uniq.sort
      categories = [] if categories.length == redis.scard(categories_id)
      categories
    end

    def clean_opts
      @opts['categories'] = sort_categories(@opts['categories'])
      @opts['q'] = normalize(@opts['q']).split(' ') unless @opts['q'].is_a?(Array)
      # .reject{ |i| i && i.length > 0 } .split(' ').reject{  Soulmate.stop_words.include?(w) }
      @opts
    end

    def set_clean_opts(params)
      @opts = self.class.default_params_hash.merge params
      clean_opts
      @cachekey = cache_id_from_opts
      @cid = category_id_from_opts
    end

    def categories_string
      @opts['categories'].empty? ? 'all' : @opts['categories'].join('')
    end

    def category_id_from_opts
      category_id(categories_string)
    end

    def cache_id_from_opts
      "#{cache_id(categories_string)}#{@opts['q'].join(':')}"
    end

    def interkeys_from_opts
      # If there isn't a query, we use a special key in redis
      @opts['q'].empty? ? [no_query_id(@cid)] : @opts['q'].map { |w| "#{@cid}#{w}" }
    end

    def cache_it_because
      redis.zinterstore(@cachekey, interkeys_from_opts)
      redis.expire(@cachekey, cache_duration) # cache_duration is set in base.rb
    end

    def matching_hashes(ids)
      return [] unless ids.size > 0
      results = redis.hmget(results_hashes_id, *ids)
      results = results.reject(&:nil?) # handle cached results for ids which have since been deleted
      results.map { |r| MultiJson.decode(r) }
    end

    def matches
      cache_it_because if !@opts['cache'] || !redis.exists(@cachekey) || redis.exists(@cachekey) == 0
      offset = (@opts['page'].to_i - 1) * @opts['per_page'].to_i
      limit = @opts['per_page'].to_i + offset - 1

      limit = 0 if limit < 0
      ids = redis.zrange(@cachekey, offset, limit) # Using 'ids', even though keys are now terms
      matching_hashes(ids)      
    end
  end
end
