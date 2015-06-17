require 'spec_helper'

describe Soulheart::Server do

  describe :search do 
    it "Has CORS headers, JSON Content-Type and it succeeds" do 
      get '/'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
      expect(last_response.headers['Access-Control-Request-Method']).to eq('*')
      expect(last_response.headers['Content-Type']).to match('json')
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body).keys).to eq(['matches'])
    end
  end

  describe :not_found do 
    it "Renders not found" do 
      get '/not-here'
      expect(last_response.headers['Content-Type']).to match('json')
      expect(last_response.status).to eq(404)
      expect(JSON.parse(last_response.body).keys).to eq(['error'])
    end
  end

  describe :status do 
    it "Has cors headers and is valid JSON" do 
      get '/status'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
      expect(last_response.headers['Access-Control-Request-Method']).to eq('*')
      expect(last_response.headers['Content-Type']).to match('json')
      expect(JSON.parse(last_response.body)['soulheart']).to match(/\d/)
    end
  end


end