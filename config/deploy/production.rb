gem 'brightbox', '>=2.3.8'
require 'brightbox/recipes'
require 'brightbox/passenger'

set :rails_env, "staging"

set :domain, "unepwcmc-013.vm.brightbox.net"
server "unepwcmc-013.vm.brightbox.net", :app, :web, :db, :primary => true

set :branch, "gid"

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      run "cd #{latest_release} && bundle exec #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile"
    end
  end
end
