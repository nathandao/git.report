require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'
require 'mina/puma'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'service.git.report'
set :deploy_to, '/var/www/service.git.report/'
set :repository, 'git@github.com:nathandao/git.report.git'
set :branch, 'master'
set :user, 'deployer'
set :forward_agent, true
set :port, '22'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config.yml', 'logs', 'data']


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
  queue! %[mkdir -p "#{deploy_to}/shared/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/sockets"]

  queue! %[mkdir -p "#{deploy_to}/shared/logs"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/logs"]

  queue! %[mkdir -p "#{deploy_to}/shared/config.yml"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config.yml"]
end

desc "Deploys the current version to the server."
  task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    to :launch do
      invoke :'puma:phased_restart'
    end
  end
end

