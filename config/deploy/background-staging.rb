set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.2-p318/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-1.9.2-p318/bin:$PATH",
  'RUBY_VERSION' => 'ruby-1.9.2-p318',
  'GEM_HOME' => '/usr/local/rvm/gems/ruby-1.9.2-p318',
  'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.2-p318',
}

set :rails_env, "staging"

# Primary domain name of your application. Used in the Apache configs
set :domain, 'ec2-107-22-142-254.compute-1.amazonaws.com'
set :branch, :generate_layer_files
set :application, "validation-background-staging"
## List of servers
server 'ec2-107-22-142-254.compute-1.amazonaws.com', :app, :web, :db, :primary => true, :jobs => true

namespace :resque do
  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end

  desc "Start resque scheduler, workers"
  task :start, :roles => :app, :only => { :jobs => true } do
    run "cd #{current_path};#{rails_env} script/resque_scheduler_daemon start"
    run "cd #{current_path};#{rails_env} script/resque_worker_daemon start"
    run "cd #{current_path};RESQUE_THIN_ENV=#{stage} bundle exec thin -d -P /tmp/thin.pid -p 9292 -R config/resque_config.ru start; true"
  end

  # test commit for nohup
  desc "Stop resque workers"
  task :stop, :roles => :app, :only => { :jobs => true } do
    run "cd #{current_path};#{rails_env} script/resque_scheduler_daemon stop"
    run "cd #{current_path};#{rails_env} script/resque_worker_daemon stop"
    run "cd #{current_path};RESQUE_THIN_ENV=#{stage} bundle exec thin -d -P /tmp/thin.pid -p 9292 -R config/resque_config.ru stop; true"
  end

  desc "Restart resque workers"
  task :restart, :roles => :app, :only => { :jobs => true } do
    run "cd #{current_path};#{rails_env} script/resque_scheduler_daemon restart"
    run "cd #{current_path};#{rails_env} script/resque_worker_daemon restart"
    [:stop, :start].each { |cmd| run "cd #{current_path};RESQUE_THIN_ENV=#{stage} bundle exec thin -d -P /tmp/thin.pid -p 9001 -R config/resque_config.ru #{cmd}; true"}
  end
end

after "deploy:stop", "resque:stop"
after "deploy:start", "resque:start"
after "deploy:restart", "resque:restart"
