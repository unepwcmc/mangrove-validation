set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.2-p318/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-1.9.2-p318/bin:$PATH",
  'RUBY_VERSION' => 'ruby-1.9.2-p318',
  'GEM_HOME' => '/usr/local/rvm/gems/ruby-1.9.2-p318',
  'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.2-p318',
}

set :domain, 'ec2-107-22-142-254.compute-1.amazonaws.com'
server 'ec2-107-22-142-254.compute-1.amazonaws.com', :app, :web, :db, :primary => true, :jobs => true

after "deploy:symlink", "deploy:restart_workers"
after "deploy:restart_workers", "deploy:restart_scheduler"

##
# Rake helper task.
# http://pastie.org/255489
# http://geminstallthat.wordpress.com/2008/01/27/rake-tasks-through-capistrano/
# http://ananelson.com/said/on/2007/12/30/remote-rake-tasks-with-capistrano/
def run_remote_rake(rake_cmd)
  rake_args = ENV['RAKE_ARGS'].to_s.split(',')
  cmd = "cd #{fetch(:latest_release)} && #{fetch(:rake, "rake")} RAILS_ENV=#{fetch(:rails_env, "production")} #{rake_cmd}"
  cmd += "['#{rake_args.join("','")}']" unless rake_args.empty?
  run cmd
  set :rakefile, nil if exists?(:rakefile)
end

namespace :deploy do
  desc "Restart Resque Workers"
  task :restart_workers, :roles => :db, :only => { :jobs => true } do
    run_remote_rake "resque:restart_workers"
  end

  desc "Restart Resque scheduler"
  task :restart_scheduler, :roles => :db, :only => { :jobs => true } do
    run_remote_rake "resque:restart_scheduler"
  end
end
