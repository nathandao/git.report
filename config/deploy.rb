require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'service.git.report'
set :deploy_to, '/var/www/service.git.report'
set :repository, 'git@github.com:nathandao/git.report.git'
set :branch, 'master'
set :user, 'deployer'
set :forward_agent, true
set :port, '22'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['./config.yml', 'logs', 'data', 'tmp/pids', 'tmp/sockets']


# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  queue %{
  echo "-----> Loading environment"
  #{echo_cmd %[source ~/.bashrc]}
}
invoke :'rbenv:load'
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do

  # Puma needs a place to store its pid file and socket file.
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")

  queue! %[mkdir -p "#{deploy_to}/shared/logs"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/logs"]

  queue! %[mkdir -p "#{deploy_to}/shared/data"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/data"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
  end
end

namespace :puma do
  set :web_server, :puma

  set_default :puma_role, -> { user }
  set_default :puma_env, -> { fetch(:rack_env, 'production') }
  set_default :puma_cmd, -> { "bundle exec puma" }
  set_default :pumactl_cmd, -> { "bundle exec pumactl" }

  set_default :puma_web, -> { "#{deploy_to}/current/config/web.ru" }
  set_default :puma_web_socket, -> { "#{deploy_to}/#{shared_path}/tmp/sockets/puma_web.sock" }
  set_default :puma_web_state, -> { "#{deploy_to}/#{shared_path}/tmp/sockets/puma_web.state" }
  set_default :pumactl_web_socket, -> { "#{deploy_to}/#{shared_path}/tmp/sockets/pumactl_web.sock" }

  set_default :puma_ws, -> { "#{deploy_to}/current/config/websocket.ru" }
  set_default :puma_ws_socket, -> { "#{deploy_to}/#{shared_path}/tmp/sockets/puma_ws.sock" }
  set_default :puma_ws_state, -> { "#{deploy_to}/#{shared_path}/tmp/sockets/puma_ws.state" }
  set_default :pumactl_ws_socket, -> { "#{deploy_to}/#{shared_path}/tmp/sockets/pumactl_ws.sock" }

  desc 'Start puma for API'
  task :start => :environment do
    queue! %[
      if [ -e '#{pumactl_web_socket}' ]; then
        echo 'Puma is already running!';
      else
        cd #{deploy_to}/#{current_path} && #{puma_cmd} #{puma_web} -d -e #{puma_env} -b 'unix://#{puma_web_socket}' --control 'unix://#{pumactl_web_socket}' --state #{puma_web_state}
      fi
    ]
  end

  desc 'Stop puma'
  task stop: :environment do
    queue! %[
      if [ -e '#{pumactl_web_socket}' ]; then
        cd #{deploy_to}/#{current_path} && #{pumactl_cmd} -S #{puma_web_state} stop
        rm -f '#{pumactl_web_socket}'
      else
        echo 'Puma is not running!';
      fi
    ]
  end

  desc 'Restart puma'
  task restart: :environment do
    invoke :'puma:stop'
    invoke :'puma:start'
  end

  desc 'Restart puma (phased restart)'
  task phased_restart: :environment do
    queue! %[
      if [ -e '#{pumactl_web_socket}' ]; then
        cd #{deploy_to}/#{current_path} && #{pumactl_cmd} #{puma_web} -S #{puma_web_state} phased-restart
      else
        echo 'Puma is not running, so starting puma...';
        cd #{deploy_to}/#{current_path} && #{puma_cmd} #{puma_web} -d -e #{puma_env} -b 'unix://#{puma_web_socket}' --control 'unix://#{pumactl_web_socket}' --state #{puma_web_state}
      fi
    ]
  end


  desc 'Start puma em-websocket'
  task :start_ws => :environment do
    queue! %[
      if [ -e '#{pumactl_ws_socket}' ]; then
        echo 'Puma em-websocket is already running!';
      else
        cd #{deploy_to}/#{current_path} && #{puma_cmd} #{puma_ws} -d -e #{puma_env} -b 'unix://#{puma_ws_socket}' --control 'unix://#{pumactl_ws_socket}' --state #{puma_ws_state}
      fi
    ]
  end

  desc 'Stop puma em-websocket'
  task stop_ws: :environment do
    queue! %[
      if [ -e '#{pumactl_ws_socket}' ]; then
        cd #{deploy_to}/#{current_path} && #{pumactl_cmd} -S #{puma_ws_state} stop
        rm -f '#{pumactl_ws_socket}'
      else
        echo 'Puma em-websocket not running!';
      fi
    ]
  end

  desc 'Restart puma em-websocket'
  task restart_ws: :environment do
    invoke :'puma_ws:stop'
    invoke :'puma_ws:start'
  end

  desc 'Restart puma (phased restart)'
  task phased_restart_ws: :environment do
    queue! %[
      if [ -e '#{pumactl_ws_socket}' ]; then
        cd #{deploy_to}/#{current_path} && #{pumactl_cmd} #{puma_ws} -S #{puma_ws_state} phased-restart
      else
        echo 'Puma em-websocket is not running, so starting puma...';
        cd #{deploy_to}/#{current_path} && #{puma_cmd} #{puma_ws} -d -e #{puma_env} -b 'unix://#{puma_ws_socket}' --control 'unix://#{pumactl_ws_socket}' --state #{puma_ws_state}
      fi
    ]
  end
end
