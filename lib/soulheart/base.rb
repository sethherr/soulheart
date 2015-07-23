module Soulheart
  class Base
    include Helpers

    attr_accessor :type

    def redis
      Soulheart.redis
    end

    def cache_duration
      10 * 60 # Setting to 10 minutes, but making it possible to edit down the line
    end

    def base_id
      ENV['RACK_ENV'] != 'test' ? 'soulheart:' : 'soulheart_test:'
    end

    def sorted_category_array
      redis.smembers(categories_id).map { |c| normalize(c) }.uniq.sort
    end

    def hidden_category_array
      redis.smembers(hidden_categories_id).map { |c| normalize(c) }.uniq.sort
    end

    def combinatored_category_array
      1.upto(sorted_category_array.size).
        flat_map { |n| sorted_category_array.combination(n).
        map { |el| el.join('') } }
    end

    def set_category_combos_array
      redis.expire category_combos_id, 0
      array = combinatored_category_array
      array.any? ? array.last.replace('all') : array << 'all'
      redis.sadd category_combos_id, array
      array
    end

    def category_combos_id
      "#{base_id}category_combos:"
    end

    def category_combos
      redis.smembers(category_combos_id)
    end

    def categories_id
      "#{base_id}categories:"
    end

    def hidden_categories_id
      "#{categories_id}hidden:"
    end

    def category_id(name = 'all')
      "#{categories_id}#{name}:"
    end

    def no_query_id(category = category_id)
      "all:#{category}"
    end

    def results_hashes_id
      "#{base_id}database:"
    end

    def cache_id(type = 'all')
      "#{base_id}cache:#{type}:"
    end
  end
end
