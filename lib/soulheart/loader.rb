module Soulheart
  class Loader < Base
    def initialize(defaults={})
      @no_all           = defaults[:no_all]
      @no_combinatorial = defaults[:no_combinatorial]
    end

    def default_items_hash(text, category)
      category ||= 'default'
      {
        'category' => normalize(category),
        'priority' => 100,
        'term' => normalize(text),
        'aliases' => [],
        'data' => {
          'text' => text,
          'category' => category
        }
      }
    end

    def add_to_categories_array(category)
      if @no_combinatorial 
        return if redis.smembers(hidden_categories_id).include?(category)
        redis.sadd hidden_categories_id, category
      elsif !redis.smembers(categories_id).include?(category)
        redis.sadd categories_id, category
      end
    end

    def delete_categories
      redis.expire category_combos_id, 0
      redis.expire categories_id, 0
      redis.expire hidden_categories_id, 0
    end

    def reset_categories(categories)
      delete_categories
      redis.sadd categories_id, categories
    end

    def delete_data(id="#{Soulheart.base_id}:")
      # delete the sorted sets for this type
      phrases = redis.smembers(Soulheart.base_id)
      redis.pipelined do
        phrases.each do |p|
          redis.del("#{id}#{p}")
        end
        redis.del(id)
      end

      # Redis can continue serving cached requests while the reload is
      # occurring. Some requests may be cached incorrectly as empty set (for requests
      # which come in after the above delete, but before the loading completes). But
      # everything will work itself out as soon as the cache expires again.
    end

    def clear_cache
      # Remove the remove_results_hash
      # has to be called before the cat_ids are cleared
      category_combos.map { |cat| redis.expire(no_query_id(category_id(cat)), 0) }
      redis.expire results_hashes_id, 0
      redis.del(results_hashes_id)
    end

    def clear(should_clear_cache = false)
      clear_cache if should_clear_cache
      category_combos.each {|cat| delete_data(category_id(cat)) }
      delete_categories
      delete_data
    end

    def load(items)
      Soulheart.stop_words # Load stop words so we don't pipeline redis_stop_words accidentally
      i = 0
      items.each do |item|
        item.replace(add_item(item)) # Replace with item return so we know we have category_id
        i += 1
      end
      set_category_combos_array.each do |category_combo|
        items.each do |item|
          if category_combo == item['category']
            next
          elsif category_combo == 'all'
            next if @no_all
          elsif @no_combinatorial
            next
          elsif !category_combo.match(item['category']) 
            next
          end
          add_item(item, category_id(category_combo), true) # send it base
          i += 1
        end
      end
      puts "Total items (including combinatorial categories):    #{i}"
    end

    def clean_hash(item)
      item['aliases'] = item['aliases'].split(',').map(&:strip) if item['aliases'] && !item['aliases'].kind_of?(Array)
      fail ArgumentError, 'Items must have text' unless item['text']
      default_items_hash(item.delete('text'), item.delete('category'))
        .tap { |i| i['data'].merge!(item.delete('data')) if item['data'] }
        .tap { |i| i['priority'] = item.delete('priority').to_f if item['priority'] }
        .merge item
    end

    def clean(item)
      item = clean_hash(item)
      item.keys.select{ |k| !%w(category priority term aliases data).include?(k) }.each do |key|
        item['data'].merge!({"#{key}" => item.delete(key)})
      end
      add_to_categories_array(item['category'])
      item
    end

    def add_item(item, category_base_id=nil, cleaned=false)      
      item = clean(item) unless cleaned
      category_base_id ||= category_id(item['category'])
      priority = (-item['priority'])
      redis.pipelined do
        redis.zadd(no_query_id(category_base_id), priority, item['term'])  # Add to master set for queryless searches
        # store the raw data in a separate key to reduce memory usage, if it's cleaned it's done
        redis.hset(results_hashes_id, item['term'], MultiJson.encode(item['data'])) unless cleaned
        phrase = ([item['term']] + (item['aliases'] || [])).join(' ')
        # Store all the prefixes
        prefixes_for_phrase(phrase).each do |p|
          redis.sadd(Soulheart.base_id, p) unless cleaned # remember prefix in a master set
          # store the normalized term in the index for each of the categories
          redis.zadd("#{category_base_id}#{p}", priority, item['term'])
        end
      end
      item
    end
  end
end
