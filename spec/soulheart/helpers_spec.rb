# coding: utf-8
require 'spec_helper'

describe Soulheart::Helpers do
  
  describe "Stop words" do 
    after :each do # Reset the stop words, just to be sure
      Soulheart.stop_words = Soulheart.default_stop_words
      require 'soulheart'
    end

    it "sets stop words from redis" do
      target = ['party', 'cool', 'awesome']
      redis = Soulheart::Base.new.redis
      redis.expire Soulheart.stop_words_id, 0
      redis.rpush Soulheart.stop_words_id, target
      require 'soulheart'
      expect(Soulheart.stop_words).to eq(target)
    end

    it "Obeys passed stop words" do 
      soulheart = Soulheart::Base.new
      Soulheart.stop_words = 'with'
      prefixes1 = ['l', 'lo', 'loc', 'lock', 't', 'th', 'the', 'i', 'in', 'ink', 'p', 'pe', 'pen']
      expect(soulheart.prefixes_for_phrase('lock with the ink pen')).to eq(prefixes1)
    end

    it "Obeys default stop words" do 
      soulheart = Soulheart::Base.new

      prefixes1 = ['k', 'kn', 'kni', 'knic', 'knick', 'knicks']
      expect(soulheart.prefixes_for_phrase('the knicks')).to eq(prefixes1)

      prefixes2 = ['t', 'te', 'tes', 'test', 'testi', 'testin', 'th', 'thi', 'this']
      expect(soulheart.prefixes_for_phrase("testin' this")).to eq(prefixes2)

      prefixes3 = ['t', 'te', 'tes', 'test']
      expect(soulheart.prefixes_for_phrase('test test')).to eq(prefixes3)

      prefixes4 = ['s', 'so', 'sou', 'soul', 'soulm', 'soulma', 'soulmat', 'soulmate']
      expect(soulheart.prefixes_for_phrase('SoUlmATE')).to eq(prefixes4)

      prefixes5 = ['测', '测试', '测试中', '测试中文', 't', 'te', 'tes', 'test']
      expect(soulheart.prefixes_for_phrase('测试中文 test')).to eq(prefixes5)

      prefixes6 = ['t', 'te', 'tet', 'teth', 'tethe', 'tether']
      expect(soulheart.prefixes_for_phrase('tether')).to eq(prefixes6)
    end
  end

  describe "normalizing" do
    after :each do # Reset the normalizing words, just to be sure
      Soulheart.normalizer = Soulheart.default_normalizer
      require 'soulheart'
    end

    it "normalizes things by default" do 
      Soulheart.normalizer = '[^\p{Word}\ ]'
      soulheart = Soulheart::Base.new
      expect(soulheart.normalize("somethin'_SPECialy888\t")).to eq('somethin_specialy888')
    end

    it "normalizes things without removing special characters" do 
      soulheart = Soulheart::Base.new
      Soulheart.normalizer = ''
      expect(soulheart.normalize(" somethin'_SPECialy888")).to eq(("somethin'_specialy888"))
    end

    it "sets normalizer from redis" do
      Soulheart.normalizer = false # Give some help with the reset ;)
      target = '\s'
      redis = Soulheart::Base.new.redis
      redis.set Soulheart.normalizer_id, target
      require 'soulheart'
      redis = Soulheart::Base.new.redis
      expect(Soulheart.normalizer).to eq(target)
    end
  end

end
