require "rvm/capistrano"
require "bundler/capistrano"
require "capistrano/ext/multistage"

set :stages, ["production", "staging", "testing"]
set :default_stage, "testing"

set :application, "SMLR Flux"
set :repository,  "git@bitbucket.org:smlrteam/smlr_flux_webserver.git"
set :branch, 'serverFeatureMatching'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
