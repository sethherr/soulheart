# encoding: utf-8
require 'spec_helper'

describe Soulheart::Matcher do

  describe :categories_array do 
    it "Returns an empty array from a string" do 
      matcher = Soulheart::Matcher.new('categories' => '')
      expect(matcher.opts['categories']).to eq([])
    end
  end

  describe :clean_opts do
    it 'Has the keys we need' do
      target_keys = %w(categories q page per_page)
      keys = Soulheart::Matcher.default_params_hash.keys
      expect((target_keys - keys).count).to eq(0)
    end

    it "Makes category empty if it's all the categories" do
      Soulheart::Loader.new.reset_categories(%w(cool test))
      cleaned = Soulheart::Matcher.new('categories' => 'cool, test')
      expect(cleaned.opts['categories']).to eq([])
    end

    it "Obeys default stop words" do 
      loader = Soulheart::Loader.new
      expect(Soulheart.stop_words).to eq(['vs', 'at', 'the'])

      prefixes1 = ['k', 'kn', 'kni', 'knic', 'knick', 'knicks']
      expect(loader.prefixes_for_phrase('the knicks')).to eq(prefixes1)

      prefixes2 = ['t', 'te', 'tes', 'test', 'testi', 'testin', 'th', 'thi', 'this']
      expect(loader.prefixes_for_phrase("testin' this")).to eq(prefixes2)

      prefixes3 = ['t', 'te', 'tes', 'test']
      expect(loader.prefixes_for_phrase('test test')).to eq(prefixes3)

      prefixes4 = ['s', 'so', 'sou', 'soul', 'soulm', 'soulma', 'soulmat', 'soulmate']
      expect(loader.prefixes_for_phrase('SoUlmATE')).to eq(prefixes4)

      prefixes5 = ['测', '测试', '测试中', '测试中文', 't', 'te', 'tes', 'test']
      expect(loader.prefixes_for_phrase('测试中文 test')).to eq(prefixes5)

      prefixes6 = ['t', 'te', 'tet', 'teth', 'tethe', 'tether']
      expect(loader.prefixes_for_phrase('tether')).to eq(prefixes6)
    end

    it "Obeys passed stop words" do 
      loader = Soulheart::Loader.new
      Soulheart.stop_words = 'with'

      prefixes1 = ['l', 'lo', 'loc', 'lock', 't', 'th', 'the', 'i', 'in', 'ink', 'p', 'pe', 'pen']
      expect(loader.prefixes_for_phrase('lock with the ink pen')).to eq(prefixes1)
    end
  end

  describe :category_id_from_opts do
    it 'Gets the id for one' do
      Soulheart::Loader.new.reset_categories(%w(cool test))
      matcher = Soulheart::Matcher.new('categories' => ['some_category'])
      expect(matcher.category_id_from_opts).to eq(matcher.category_id('some_category'))
    end

    it 'Gets the id for all of them' do
      Soulheart::Loader.new.reset_categories(%w(cool test boo))
      matcher = Soulheart::Matcher.new('categories' => 'cool, boo, test')
      expect(matcher.category_id_from_opts).to eq(matcher.category_id('all'))
    end
  end

  describe :categories_string do
    it 'Does all if none' do
      Soulheart::Loader.new.reset_categories(%w(cool test))
      matcher = Soulheart::Matcher.new('categories' => '')
      expect(matcher.categories_string).to eq('all')
    end
    it 'Correctly concats a string of categories' do
      Soulheart::Loader.new.reset_categories(['cool', 'some_category', 'another cat', 'z9', 'stuff'])
      matcher = Soulheart::Matcher.new('categories' => 'some_category, another cat, z9')
      expect(matcher.categories_string).to eq('another catsome_categoryz9')
    end
  end

  describe :matches do
    it 'With no params, gets all the matches, ordered by priority and name' do
      store_terms_fixture
      opts = { 'per_page' => 100, 'cache' => false }
      matches = Soulheart::Matcher.new(opts).matches
      expect(matches.count).to be > 10
      expect(matches[0]['text']).to eq('Jamis')
      expect(matches[1]['text']).to eq('Surly')
    end

    it 'With no query but with categories, matches categories' do
      store_terms_fixture
      opts = { 'per_page' => 100, 'cache' => false, 'categories' => 'manufacturer' }
      matches = Soulheart::Matcher.new(opts).matches
      expect(matches.count).to eq(4)
      expect(matches[0]['text']).to eq('Brooks England LTD.')
      expect(matches[1]['text']).to eq('Sram')
    end

    it 'Gets the matches matching query and priority for one item in query, all categories' do
      store_terms_fixture
      opts = { 'per_page' => 100, 'q' => 'j', 'cache' => false }
      matches = Soulheart::Matcher.new(opts).matches
      expect(matches.count).to eq(3)
      expect(matches[0]['text']).to eq('Jamis')
    end

    it 'Gets the matches matching query and priority for one item in query, one category' do
      store_terms_fixture
      opts = { 'per_page' => 100, 'q' => 'j', 'cache' => false, 'categories' => 'manufacturer' }
      matches = Soulheart::Matcher.new(opts).matches
      expect(matches.count).to eq(2)
      expect(matches[0]['text']).to eq('Jannd')
    end

    it "Matches Chinese" do 
      store_terms_fixture
      opts = { 'q' => "中国" }
      matches = Soulheart::Matcher.new(opts).matches
      expect(matches.length).to eq(1)
      expect(matches[0]['text']).to eq("中国佛山 李小龙")
    end

    it "Finds by aliases" do 
      store_terms_fixture
      opts = { 'q' => 'land shark stadium' }
      matches = Soulheart::Matcher.new(opts).matches
      expect(matches.length).to eq(1)
      expect(matches[0]['text']).to eq('Sun Life Stadium')
    end

    it "Doesn't duplicate when matching both alias and the normal term" do 
      store_terms_fixture
      opts = { 'q' => 'stadium' }
      matches = Soulheart::Matcher.new(opts).matches
      expect(matches.length).to eq(5)
    end

    it 'Gets pages and uses them' do
      Soulheart::Loader.new.clear(true)
      # Pagination wrecked my mind, hence the multitude of tests]
      items = [
        { 'text' => 'First item', 'priority' => '11000' },
        { 'text' => 'First atom', 'priority' => '11000' },
        { 'text' => 'Second item', 'priority' => '1999' },
        { 'text' => 'Third item', 'priority' => 1900 },
        { 'text' => 'Fourth item', 'priority' => 1800 },
        { 'text' => 'Fifth item', 'priority' => 1750 },
        { 'text' => 'Sixth item', 'priority' => 1700 },
        { 'text' => 'Seventh item', 'priority' => 1699 }
      ]
      loader = Soulheart::Loader.new
      loader.delete_categories
      loader.load(items)
      page1 = Soulheart::Matcher.new('per_page' => 1, 'cache' => false).matches
      expect(page1[0]['text']).to eq('First atom')

      page2 = Soulheart::Matcher.new('per_page' => 1, 'page' => 2, 'cache' => false).matches
      expect(page2[0]['text']).to eq('First item')

      page2 = Soulheart::Matcher.new('per_page' => 1, 'page' => 3, 'cache' => false).matches
      expect(page2.count).to eq(1)
      expect(page2[0]['text']).to eq('Second item')

      page3 = Soulheart::Matcher.new('per_page' => 2, 'page' => 3, 'cache' => false).matches
      expect(page3[0]['text']).to eq('Fourth item')
      expect(page3[1]['text']).to eq('Fifth item')
    end
  end
end
