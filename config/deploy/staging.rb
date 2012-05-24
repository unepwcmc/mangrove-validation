# Generated with 'brightbox' on Thu Apr 21 11:12:49 +0100 2011
gem 'brightbox', '>=2.3.8'
require 'brightbox/recipes'
require 'brightbox/passenger'

set :rails_env, "staging"
# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-005.vm.brightbox.net"

## List of servers
server "unepwcmc-005.vm.brightbox.net", :app, :web, :db, :primary => true

set :branch, "gid"

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      run "cd #{latest_release} && bundle exec #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile"
    end
  end
end
