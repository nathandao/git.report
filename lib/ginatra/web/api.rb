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
        if [:from, :til, :in, :labels, :limit, :time_stamps].include? v[0].to_sym
          prms[v[0].to_sym] = v[1] 
        end
        prms
      }
    end

    get '/api/init_data' do
      threads = []
      repo_list = nil
      commits = nil
      overview = nil

      # Get all relevant data to initialize react dashboard
      threads << Thread.new{ repo_list = get_repo_list }
      threads << Thread.new{ commits = get_commits }
      threads << Thread.new{ overview = get_overview }
      threads.each { |thread| thread.join }

      { repoList: repo_list, commits: commits , overview: overview }.to_json
    end

    get '/api/repo_list' do
      get_repo_list.to_json
    end

    get '/api/commits' do
      get_commits.to_json
    end

    get '/api/overview' do
      get_overview.to_json
    end

    def get_repo_list
      repo_ids = Ginatra::Helper.repo_ids_from_param_in(@filter[:in])

      repos = Ginatra::Config.repositories.select{ |key| repo_ids.include?(key) }
      repos.map { |key, value|
        {
          id: key,
          name: value['name'],
          color: value['color']
        }
      }
    end

    def get_commits
      repo_ids = Ginatra::Helper.repo_ids_from_param_in(@filter[:in])
      commits = Ginatra::RedisCache.get_commits(repo_ids)

      if !@filter[:from].nil? || !@filter[:til].nil?
        @filter[:from] ||= Time.new(0).to_s
        @filter[:til] ||= Time.now.to_s
        from = Ginatra::Helper.epoch_time(@filter[:from])
        til = Ginatra::Helper.epoch_time(@filter[:til])
        commits.each do |commit|
          commits[commit[0]] = commit[1].select{ |commit_value|
            commit_value[:commit_timestamp] >= from && commit_value[:commit_timestamp] <= til
          }
        end
      end

      commits.map{ |repo_commit|
        { repoId: repo_commit[0], commits: repo_commit[1] }
      }
    end

    def get_overview
      repo_ids = Ginatra::Helper.repo_ids_from_param_in(@filter[:in])
      Ginatra::RedisCache.get_overview(repo_ids).map{ |repo_data|
        { repoId: repo_data[0], overview: repo_data[1] }
      }
    end
  end
end
