set :deploy_to, '/home/ubuntu/flux_web/'
set :rails_env, 'testing'
set :user, 'ubuntu'
set :use_sudo, false
set :rvm_ruby_string, 'ruby-1.9.3-p484'
set :ssh_options, { forward_agent: true, keys: File.join(ENV["HOME"], ".ssh", "SMLR_primary_NV.pem") }
server "54.221.222.71", :web, :app, :db, primary: true
