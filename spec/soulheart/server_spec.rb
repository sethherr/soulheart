require 'spec_helper'

describe Soulheart::Server do
  describe :search do
    it 'Has CORS headers, JSON Content-Type and it succeeds' do
      get '/'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
      expect(last_response.headers['Access-Control-Request-Method']).to eq('*')
      expect(last_response.headers['Content-Type']).to match('json')
      expect(last_response.status).to eq(200)
      expect(MultiJson.load(last_response.body).keys).to eq(['matches'])
    end
  end

  describe :not_found do
    it 'Renders not found' do
      get '/not-here'
      expect(last_response.headers['Content-Type']).to match('json')
      expect(last_response.status).to eq(404)
      expect(MultiJson.load(last_response.body).keys).to eq(['error'])
    end
  end

  describe :categories do
    it 'Renders the categories' do
      Soulheart::Loader.new.reset_categories(%w(sweet test cool))
      get '/categories'
      expect(last_response.headers['Content-Type']).to match('json')
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
      expect(last_response.headers['Access-Control-Request-Method']).to eq('*')
      expect(last_response.headers['Content-Type']).to match('json')
      expect(MultiJson.load(last_response.body)['categories']).to eq(['cool', 'sweet', 'test'])
    end
  end

  describe :info do
    it 'Has cors headers and is valid JSON' do
      get '/info'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
      expect(last_response.headers['Access-Control-Request-Method']).to eq('*')
      expect(last_response.headers['Content-Type']).to match('json')
      result = MultiJson.load(last_response.body)

      expect(result['soulheart_version']).to match(/\d/)
      expect(result['current_time']).to_not be_nil
      expect(result['redis_used_memory']).to_not be_nil
      expect(result['json_serializer']).to_not be_nil
      expect(result['stop_words']).to_not be_nil
      expect(result['normalizer']).to_not be_nil
    end
  end
end
