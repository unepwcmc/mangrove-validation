set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.2-p318/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-1.9.2-p318/bin:$PATH",
  'RUBY_VERSION' => 'ruby-1.9.2-p318',
  'GEM_HOME' => '/usr/local/rvm/gems/ruby-1.9.2-p318',
  'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.2-p318',
}

set :user, 'rails'
set :use_sudo, false

set :domain, 'validation.unep-wcmc.org'
server 'validation.unep-wcmc.org', :app, :web, :db, :primary => true, :jobs => true

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:auth_methods] = ["publickey"]
ssh_options[:keys] = ["~/.ssh/ChefDeployNew.pem"]

set :rails_env, "production"

#after "deploy:symlink", "deploy:restart_workers"
#after "deploy:restart_workers", "deploy:restart_scheduler"

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/cartodb_config.yml #{release_path}/config/cartodb_config.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/http_auth_config.yml #{release_path}/config/http_auth_config.yml"
    run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  end
end

before 'deploy:finalize_update', 'deploy:symlink_shared'

# bundler bootstrap
require 'bundler/capistrano'
