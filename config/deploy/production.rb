set :deploy_to, '/home/ec2-user/flux_app/'
set :rails_env, 'production'
set :user, 'ec2-user'
set :use_sudo, false
set :rvm_type, :user
# set :rvm_ruby_string, 'ruby-1.9.3-p484'
set :ssh_options, { forward_agent: true }
server "fluxapp.normative.com", :web, :app, :db, primary: true
