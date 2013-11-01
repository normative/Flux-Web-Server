set :deploy_to, '/home/ec2-user/flux_web/'
set :rails_env, 'staging'
set :user, 'ec2-user'
set :use_sudo, false
set :ssh_options, { forward_agent: true, keys: File.join(ENV["HOME"], ".ssh", "SMLR_primary_NV.pem") }
server "54.221.222.71", :web, :app, :db, primary: true
