# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-007.vm.brightbox.net"

## List of servers
server "unepwcmc-007.vm.brightbox.net", :app, :web, :db, :primary => true
