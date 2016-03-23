require 'spec_helper'

describe Soulheart do
  it 'Has a version number' do
    expect(Soulheart::VERSION).not_to be nil
  end

  it 'Has a test base_id' do
    expect(Soulheart.base_id).to eq('soulheart_test:')
  end

  it 'Has a cache expiration time' do
    expect(Soulheart::Base.new.cache_duration).to eq(600)
  end

  it 'Uses the correct driver for redis' do
    redis = Soulheart::Base.new.redis
    if RUBY_ENGINE == 'jruby'
      expect(redis.client.options[:driver].to_s).to match /ruby/i
    else
      expect(redis.client.options[:driver].to_s).to match /hiredis/i
    end
  end

  it 'gets the sorted_category_array without hidden_categories' do 
    base = Soulheart::Base.new
    base.redis.expire base.categories_id, 0
    base.redis.sadd base.categories_id, ['George', 'category one', 'other thing ']
    base.redis.sadd base.hidden_categories_id, ['scotch', 'foobar']
    expect(base.sorted_category_array).to eq(['category one', 'george', 'other thing'])
  end

  it 'gets the hidden_category_array' do 
    base = Soulheart::Base.new
    base.redis.expire base.hidden_categories_id, 0
    base.redis.sadd base.categories_id, ['George', 'category one', 'other thing ']
    base.redis.sadd base.hidden_categories_id, ['scotch', 'foobar']
    expect(base.hidden_category_array).to eq(['foobar', 'scotch'])
  end

  it 'Combinates all the things' do
    base = Soulheart::Base.new
    base.redis.expire base.categories_id, 0
    base.redis.sadd base.categories_id, ['George', 'category one', 'other thing ']
    result = base.set_category_combos_array
    expect(result.include?('category one')).to be_true
    expect(result.include?('george')).to be_true
    expect(result.include?('other thing')).to be_true
    expect(result.include?('georgeother thing')).to be_true
    expect(result.include?('category oneother thing')).to be_true
    expect(result.include?('category onegeorge')).to be_true
    expect(result.include?('georgecategory one')).to be_false
    expect(result.include?('all')).to be_true
    expect(result.include?('category onegeorgeother thing')).to be_false
    expect(base.redis.smembers(base.category_combos_id) - result).to eq([])
  end

  it "runs file loader with passed options" do 
    opts = {
      batch_size: 10,
      no_all: true,
      no_combinatorial: true,
      normalize_regex: 'filename',
      normalize_no_sym: true,
      remove_results: true,
      no_log: true,
    }
    # Not sure how to test option passing without stubbing out initialize
    # Stubbing initialize prints a warning about how it's a bad idea tho...
    expect_any_instance_of(Soulheart::FileHandler).to receive(:initialize).with(opts)
    expect_any_instance_of(Soulheart::FileHandler).to receive(:load).with('cool filename.stuff')
    Soulheart.load_file('cool filename.stuff', opts)
  end

  it "runs item loader with passed options" do 
    items = [{'text' => 'stuff'}, {'text' => 'fun'}]
    opts = {no_all: true, no_combinatorial: true}
    # Not sure how to test option passing without stubbing out initialize
    # Stubbing initialize prints a warning about how it's a bad idea tho...
    expect_any_instance_of(Soulheart::Loader).to receive(:initialize).with(opts)
    expect_any_instance_of(Soulheart::Loader).to receive(:load).with(items)
    Soulheart.load_items(items, opts)
  end
end
