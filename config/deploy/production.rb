set :rails_env, "production"
# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-012.vm.brightbox.net"
## List of servers
server "unepwcmc-012.vm.brightbox.net", :app, :web, :db, :primary => true

set :application, "gid"
set :server_name, "gid".unepwcmc-012.vm.brightbox.net"
set :sudo_user, "rails"
set :app_port, "80" 


desc "Configure VHost"
task :config_vhost do
vhost_config =<<-EOF
server {
  listen 80;
  client_max_body_size 4G;
  server_name #{application}.unepwcmc-012.vm.brightbox.net #{application}.sw02.matx.info;
  keepalive_timeout 5;
  root #{deploy_to}/current/public;
  passenger_enabled on;
  rails_env production;

  add_header 'Access-Control-Allow-Origin' *;
  add_header 'Access-Control-Allow-Methods' "GET, POST, PUT, DELETE, OPTIONS";
  add_header 'Access-Control-Allow-Headers' "X-Requested-With, X-Prototype-Version";
  add_header 'Access-Control-Max-Age' 1728000;
  
  gzip on;
  location ^~ /assets/ {
    expires max;
    add_header Cache-Control public;
  }
  
  if (-f $document_root/system/maintenance.html) {
    return 503;
  }

  error_page 500 502 504 /500.html;
  location = /500.html {
    root #{deploy_to}/public;
  }

  error_page 503 @maintenance;
  location @maintenance {
    rewrite  ^(.*)$  /system/maintenance.html break;
  }
}
EOF
put vhost_config, "/tmp/vhost_config"
sudo "mv /tmp/vhost_config /etc/nginx/sites-available/#{application}"
sudo "ln -s /etc/nginx/sites-available/#{application} /etc/nginx/sites-enabled/#{application}"
end
 
after "deploy:setup", :config_vhost

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
