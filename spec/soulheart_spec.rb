require 'spec_helper'

describe Soulheart do
  it 'Has a version number' do
    expect(Soulheart::VERSION).not_to be nil
  end

  it 'Has a test base_id' do
    expect(Soulheart::Base.new.base_id).to eq('soulheart_test:')
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
end
