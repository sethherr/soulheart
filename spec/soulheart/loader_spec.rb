require 'spec_helper'

describe Soulheart::Loader do
  describe :clean_data do
    it 'sets the default category, priority and normalizes term' do
      item = { 'text' => '  FooBar' }
      result = Soulheart::Loader.new.clean_hash(item)
      expect(result['priority']).to eq(100)
      expect(result['term']).to eq('foobar')
      expect(result['category']).to eq('default')
      expect(result['data']['text']).to eq('  FooBar')
    end

    it "doesn't overwrite the submitted params (including the data-text)" do
      item = {
        'text' => 'Cool ',
        'priority' => '50',
        'category' => 'Gooble',
        'aliases' => 'deck, fly',
        'data' => {
          'text' => ' Cspan',
          'id' => 199,
          'category' => 'Stuff'
        }
      }
      result = Soulheart::Loader.new.clean_hash(item)
      expect(result['term']).to eq('cool')
      expect(result['priority']).to eq(50)
      expect(result['aliases']).to eq(['deck', 'fly'])
      expect(result['data']['id']).to eq(199)
      expect(result['data']['text']).to eq(' Cspan')
      expect(result['category']).to eq('gooble')
      expect(result['data']['category']).to eq('Stuff')
    end

    it 'raises argument error if no text is passed' do
      expect do
        Soulheart::Loader.new.clean_hash('name' => 'stuff')
      end.to raise_error(/must have/i)
    end
  end

  describe :clean do 
    it "calls add to category" do
      integration = Soulheart::Loader.new
      item = {'text' => 'something'}
      expect(integration).to receive(:add_to_categories_array)
      integration.clean(item)
    end
  end

  describe :add_to_categories_array do 
    it "adds to hidden category if hidden" do 
      loader = Soulheart::Loader.new(no_combinatorial: true)
      loader.clear(true)
      loader.add_to_categories_array('george')
      expect(loader.hidden_category_array).to eq(['george'])
    end
    it "adds to normal category" do 
      loader = Soulheart::Loader.new
      loader.clear(true)
      loader.add_to_categories_array('george')
      expect(loader.sorted_category_array).to eq(['george'])
    end
  end

  describe :add_item do
    it 'adds an item, adds prefix scopes, adds category' do
      item = {
        'text' => 'Brompton Bicycle',
        'priority' => 50,
        'category' => 'Gooble',
        'data' => {
          'id' => 199
        }
      }
      loader = Soulheart::Loader.new
      loader.clear(true)
      redis = loader.redis
      loader.add_item(item)
      redis = loader.redis
      target = "{\"text\":\"Brompton Bicycle\",\"category\":\"Gooble\",\"id\":199}"
      result = redis.hget(loader.results_hashes_id, 'brompton bicycle')
      expect(result).to eq(target)
      prefixed = redis.zrange "#{loader.category_id('gooble')}brom", 0, -1
      expect(prefixed[0]).to eq('brompton bicycle')
      expect(redis.smembers(loader.categories_id).include?('gooble')).to be_true
    end

    it 'deals with csv format, with data- prefixed items' do
      item = {
        'text' => 'Brompton Bicycle',
        'priority' => 50,
        'category' => 'Gooble',
        'id' => 199,
        'url' => 'http://something.com',
      }
      loader = Soulheart::Loader.new
      loader.clear(true)
      redis = loader.redis
      loader.add_item(item)
      redis = loader.redis
      target = "{\"text\":\"Brompton Bicycle\",\"category\":\"Gooble\",\"id\":199,\"url\":\"http://something.com\"}"
      result = redis.hget(loader.results_hashes_id, 'brompton bicycle')
      expect(result).to eq(target)
    end

  end

  describe :load do
    it 'stores terms by priority and adds categories for each possible category combination' do
      items = []
      file = File.read('spec/fixtures/multiple_categories.json')
      file.each_line { |l| items << MultiJson.decode(l) }
      loader = Soulheart::Loader.new
      loader.clear(true)
      redis = loader.redis
      loader.delete_categories
      loader.load(items)

      cat_prefixed = redis.zrange "#{loader.category_id('frame manufacturermanufacturer')}brom", 0, -1
      expect(cat_prefixed.count).to eq(1)
      expect(redis.smembers(loader.categories_id).count).to be > 3
      prefixed = redis.zrange "#{loader.category_id('all')}bro", 0, -1
      expect(prefixed.count).to eq(2)
      expect(prefixed[0]).to eq('brompton bicycle')
    end

    it "stores terms by priority and doesn't add run categories if none are present" do
      items = [
        { 'text' => 'cool thing', 'category' => 'AWESOME' },
        { 'text' => 'Sweet', 'category' => ' awesome' }
      ]
      loader = Soulheart::Loader.new
      loader.clear(true)
      redis = loader.redis
      loader.delete_categories
      loader.load(items)
      expect(redis.smembers(loader.category_combos_id).count).to eq(1)
    end

    it "doesn't add category if no_combinatorial" do 
      items = []
      file = File.read('spec/fixtures/multiple_categories.json')
      file.each_line { |l| items << MultiJson.decode(l) }
      loader = Soulheart::Loader.new(no_combinatorial: true)
      loader.clear(true)
      redis = loader.redis
      loader.delete_categories
      loader.load(items)

      cat_prefixed = redis.zrange "#{loader.category_id('frame manufacturer')}brom", 0, -1
      expect(cat_prefixed.count).to eq(1)
      multicat_prefixed = redis.zrange "#{loader.category_id('frame manufacturermanufacturer')}brom", 0, -1
      expect(multicat_prefixed.count).to eq(0)
      expect(loader.hidden_category_array.count).to eq(4)
      expect(loader.category_combos).to eq(['all'])
      prefixed = redis.zrange "#{loader.category_id('all')}brom", 0, -1
      expect(prefixed.count).to eq(1)
    end


    it "doesn't add all if no_all" do 
      items = []
      file = File.read('spec/fixtures/multiple_categories.json')
      file.each_line { |l| items << MultiJson.decode(l) }
      loader = Soulheart::Loader.new(no_all: true)
      loader.clear(true)
      redis = loader.redis
      loader.delete_categories
      loader.load(items)

      cat_prefixed = redis.zrange "#{loader.category_id('frame manufacturermanufacturer')}brom", 0, -1
      expect(cat_prefixed.count).to eq(1)
      expect(loader.category_combos.count).to be > 3
      prefixed = redis.zrange "#{loader.category_id('all')}b", 0, -1
      expect(prefixed.count).to eq(0)
    end

    it "doesn't add all or category if no_all and no_combinatorial" do 
      items = []
      file = File.read('spec/fixtures/multiple_categories.json')
      file.each_line { |l| items << MultiJson.decode(l) }
      loader = Soulheart::Loader.new(no_combinatorial: true, no_all: true)
      loader.clear(true)
      redis = loader.redis
      loader.delete_categories
      loader.load(items)

      cat_prefixed = redis.zrange "#{loader.category_id('frame manufacturer')}brom", 0, -1
      expect(cat_prefixed.count).to eq(1)
      multicat_prefixed = redis.zrange "#{loader.category_id('frame manufacturermanufacturer')}brom", 0, -1
      expect(multicat_prefixed.count).to eq(0)
      expect(loader.category_combos).to eq(['all']) # We still need an all category, or querying will break
      prefixed = redis.zrange "#{loader.category_id('all')}b", 0, -1
      expect(prefixed.count).to eq(0)
    end
  end

  describe :clear do 
    it "deletes everything, but leaves the cache" do
      items = [
        {'text' => 'Brompton Bicycle', 'category' => 'Gooble'},
        {'text' => 'Surly Bicycle', 'category' => 'Bluster'},
        {"text" => "Defaulted"}
      ]
      search_opts = {'categories' => 'Bluster, Gooble', 'q' => 'brom'}

      loader = Soulheart::Loader.new

      redis = loader.redis
      loader.load(items)
      redis = loader.redis
      expect(redis.hget(loader.results_hashes_id, 'brompton bicycle').length).to be > 0
      expect((redis.zrange "#{loader.category_id('gooble')}brom", 0, -1)[0]).to eq("brompton bicycle")
      expect((redis.zrange "#{loader.category_id('blustergooble')}brom", 0, -1)[0]).to eq("brompton bicycle")
      
      matches1 = Soulheart::Matcher.new(search_opts).matches
      expect(matches1[0]['text']).to eq("Brompton Bicycle")
      
      loader.clear
      expect(redis.hget(loader.results_hashes_id, 'brompton bicycle')).to_not be_nil
      prefixed = redis.zrange "#{loader.category_id('gooble')}brom", 0, -1
      expect(prefixed).to be_empty
      expect(redis.zrange "#{loader.category_id('blustergooble')}brom", 0, -1).to be_empty
      expect(redis.smembers(loader.categories_id).include?('gooble')).to be_false

      matches2 = Soulheart::Matcher.new(search_opts).matches
      expect(matches2[0]['text']).to eq("Brompton Bicycle")
      expect(Soulheart::Matcher.new(search_opts.merge("cache" => false)).matches).to be_empty
    end
  end
 
end
