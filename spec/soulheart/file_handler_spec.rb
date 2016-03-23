require 'spec_helper'

describe Soulheart::FileHandler do
  before :each do 
    @loader = Soulheart::Loader.new
    @loader.clear(true)
    @redis = @loader.redis
    @opts = {no_log: true}
  end
  describe :load do
    context "CSV with name only" do
      before do 
        file = 'spec/fixtures/name_only.csv'
        Soulheart::FileHandler.new(@opts).load(file)
      end
      it 'loads all 4 items' do
        matches = @redis.zrange "#{@loader.category_id('all')}3", 0, -1
        
        expect(matches.count).to eq(4)
      end
    end

    context "CSV with the wrong extension" do
      before do 
        file = 'spec/fixtures/wrong_extension.tsv'
        Soulheart::FileHandler.new(@opts).load(file)
      end
      it 'loads all 4 items' do
        matches = @redis.zrange "#{@loader.category_id('all')}3", 0, -1
        
        expect(matches.count).to eq(4)
      end
    end

    context "JSON stream from remote url" do
      before do 
        file = 'https://raw.githubusercontent.com/sethherr/soulheart/master/spec/fixtures/multiple_categories.json'
        Soulheart::FileHandler.new(@opts).load(file)
      end
      it 'loads all 10 items' do
        matches = @redis.zrange "#{@loader.category_id('all')}b", 0, -1

        expect(matches.count).to eq(3)
      end
    end

    context "JSON non stream" do
      before do 
        file = 'spec/fixtures/non_stream.json'
        Soulheart::FileHandler.new(@opts).load(file)
      end
      it 'loads all the items' do
        matches = @redis.zrange "#{@loader.category_id('all')}b", 0, -1
        
        expect(matches.count).to eq(3)
      end
    end
  end

  describe 'load_json' do
    context 'single line non-stream json' do
      it 'loads the JSON' do
        file = 'spec/fixtures/non_stream_one_line.json'
        Soulheart::FileHandler.new({no_log: true}).load_json(File.open(file))
        matches = @redis.zrange "#{@loader.category_id('all')}b", 0, -1
        expect(matches.count).to eq(3)
      end
    end
  end
 
end
