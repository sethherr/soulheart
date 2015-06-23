module Soulheart
  class Loader < Base
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

    def delete_categories
      redis.expire categories_id, 0
    end

    def reset_categories(categories)
      delete_categories
      redis.sadd categories_id, categories
    end

    def delete_data
      # delete the sorted sets for this type
      phrases = redis.smembers(base_id)
      redis.pipelined do
        phrases.each do |p|
          redis.del("#{base_id}:#{p}")
        end
        redis.del(base_id)
      end

      # Redis can continue serving cached requests for this type while the reload is
      # occuring. Some requests may be cached incorrectly as empty set (for requests
      # which come in after the above delete, but before the loading completes). But
      # everything will work itself out as soon as the cache expires again.

      # delete the data stored for this type
      redis.del(results_hashes_id)
    end

    def load(items)
      delete_data
      # Replace with item return so we know we have category_id
      items.each { |item| item.replace(add_item(item)) }
      set_category_combos_array.each do |category_combo|
        items.each do |item|
          next unless category_combo.match(item['category']) || category_combo == 'all'
          add_item(item, category_id(category_combo), cleaned: true) # send it base
        end
      end
    end

    def clean(item)
      fail ArgumentError, 'Items must have text' unless item['text']
      default_items_hash(item.delete('text'), item.delete('category'))
        .tap { |i| i['data'].merge!(item.delete('data')) if item['data'] }
        .tap { |i| i['priority'] = item.delete('priority').to_f if item['priority'] }
        .merge item
    end

    def add_item(item, category_base_id = nil, cleaned: false)
      unless cleaned
        item = clean(item)
        category_base_id ||= category_id(item['category'])
        unless redis.smembers(categories_id).include?(item['category'])
          redis.sadd categories_id, item['category']
        end
      end
      redis.pipelined do
        redis.zadd(no_query_id(category_base_id), item['priority'], item['term']) # Add to master set for queryless searches
        # store the raw data in a separate key to reduce memory usage, if it's cleaned it's done
        redis.hset(results_hashes_id, item['term'], MultiJson.encode(item['data'])) unless cleaned
        phrase = ([item['term']] + (item['aliases'] || [])).join(' ')
        # Store all the prefixes
        prefixes_for_phrase(phrase).each do |p|
          redis.sadd(base_id, p) unless cleaned # remember prefix in a master set
          # store the normalized term in the index for each of the categories
          redis.zadd("#{category_base_id}#{p}", item['priority'], item['term'])
        end
      end
      item
    end

    # remove only cares about an item's id, but for consistency takes an object
    def remove(item)
      prev_item = Soulheart.redis.hget(base_id, item['term'])
      if prev_item
        prev_item = MultiJson.decode(prev_item)
        # undo the operations done in add
        Soulheart.redis.pipelined do
          Soulheart.redis.hdel(base_id, prev_item['term'])
          phrase = ([prev_item['term']] + (prev_item['aliases'] || [])).join(' ')
          prefixes_for_phrase(phrase).each do |p|
            Soulheart.redis.srem(base_id, p)
            Soulheart.redis.zrem("#{base_id}:#{p}", prev_item['term'])
          end
        end
      end
    end
  end
end
