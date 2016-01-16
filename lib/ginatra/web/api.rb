require 'sinatra/base'
require 'sinatra/cross_origin'

module Ginatra
  class API < Sinatra::Base
    register Sinatra::CrossOrigin

    configure do
      enable :cross_origin
    end

    options '*' do
      response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
      200
    end

    before '/api/*' do
      content_type 'application/json'
      @filter = params.inject({}) { |prms, v|
        if [:from, :til, :in, :labels, :limit,
          :time_stamps].include? v[0].to_sym
          prms[v[0].to_sym] = v[1] 
        end
        prms
      }
    end

    get '/api/repo_list' do
      repos = Ginatra::Config.repositories
      repos.map { |key, value|
        { id: key,
          name: value['name'],
          color: value['color']
        }
      }.to_json
    end

    get '/api/commits' do
      Ginatra::Stat.commits(@filter).map{ |repo|
        { repoId: repo[0], commits: repo[1] }
      }.to_json
    end

    get '/api/overview' do
      Ginatra::Stat.overview(@filter).map{ |repo|
        { repoId: repo[0], data: repo[1] }
      }.to_json
    end
  end
end
