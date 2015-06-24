require 'spec_helper'

describe Soulheart::Matcher do
  describe :clean_opts do
    it 'Has the keys we need' do
      target_keys = %w(categories q page per_page)
      keys = Soulheart::Matcher.default_params_hash.keys
      expect((target_keys - keys).count).to eq(0)
    end

    it "makes category empty if it's all the categories" do
      Soulheart::Loader.new.reset_categories(%w(cool test))
      cleaned = Soulheart::Matcher.new('categories' => 'cool, test')
      expect(cleaned.opts['categories']).to eq([])
    end

    it 'obeys stop words'
  end

  describe :category_id_from_opts do
    it 'gets the id for one' do
      Soulheart::Loader.new.reset_categories(%w(cool test))
      matcher = Soulheart::Matcher.new('categories' => ['some_category'])
      expect(matcher.category_id_from_opts).to eq(matcher.category_id('some_category'))
    end

    it 'gets the id for all of them' do
      Soulheart::Loader.new.reset_categories(%w(cool test boo))
      matcher = Soulheart::Matcher.new('categories' => 'cool, boo, test')
      expect(matcher.category_id_from_opts).to eq(matcher.category_id('all'))
    end
  end

  describe :categories_string do
    it 'does all if none' do
      Soulheart::Loader.new.reset_categories(%w(cool test))
      matcher = Soulheart::Matcher.new('categories' => '')
      expect(matcher.categories_string).to eq('all')
    end
    it 'correctly concats a string of categories' do
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

    it 'Gets pages and uses them' do
      Soulheart::Loader.new.clear(remove_results: true)
      # Pagination wrecked my mind, hence the multitude of expectations
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
