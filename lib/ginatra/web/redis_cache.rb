require 'redis'
require 'json'

module Ginatra
  class RedisCache
    @redis ||= Redis.new(Ginatra::Config.redis)
    class << self
      # Create all cache data.
      def update_cache(repo_ids)
        update_overview(repo_ids)
        update_commits(repo_ids)
      end

      # Cache repo overview data in Redis cache
      # with key overview_repoID.
      def update_overview(repo_ids)
        Ginatra::Helper.query_overview({ in: repo_ids }).each do |repo_data|
          @redis.set(
            'overview_' + repo_data[0],
            repo_data[1].to_json
          )
        end
      end

      # Get repo overview data from Redis. Only repoIds
      # is required as param.
      def get_overview(repo_ids)
        result = {}
        repo_ids.each do |repo_id|
          result[repo_id] = JSON.parse(@redis.get('overview_' + repo_id), symbolize_names: true)
        end
        result
      end

      # Cache past year commit data in Redis cache.
      def update_commits(repo_ids)
        params = { in: repo_ids }
        now = Time.now
        year = now.year
        month = now.month
        day = now.day - 7
        params[:from] = Time.new(year, month, day).to_s
        Ginatra::Helper.query_commits(params).each do |repo_data|
          @redis.set(
            'commits_' + repo_data[0],
            repo_data[1].to_json
          )
        end
      end

      # Get all commits data in redis cache.
      def get_commits(repo_ids)
        result = {}
        repo_ids.each do |repo_id|
          result[repo_id] = JSON.parse(@redis.get('commits_' + repo_id), symbolize_names: true)
        end
        result
      end
    end
  end
end
