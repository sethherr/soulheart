require 'sinatra/base'
require 'soulheart'
require 'rack/contrib'

module Soulheart

  class Server < Sinatra::Base
    include Helpers
    
    before do
      content_type 'application/json', :charset => 'utf-8'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, GET, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end
        
    get '/' do
      matches = Matcher.new(params).matches
      MultiJson.encode({ results:  matches })
    end

    get '/status' do 
      MultiJson.encode({ soulheart: Soulheart::VERSION, :status   => "ok" })
    end
    
    not_found do
      content_type 'application/json', :charset => 'utf-8'
      MultiJson.encode({ :error => "not found" })
    end
    
  end
end
