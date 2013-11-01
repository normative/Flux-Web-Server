set :deploy_to, '/home/ec2-user/flux_web/'
set :rails_env, 'staging'
set :user, 'ec2-user'
set :use_sudo, false
server "54.221.254.230", :web, :app, :db, primary: true
