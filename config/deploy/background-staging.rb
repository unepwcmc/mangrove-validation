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
server 'ec2-107-22-142-254.compute-1.amazonaws.com', :app, :web, :db, :primary => true
