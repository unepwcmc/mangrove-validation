set :default_stage, 'staging'
require 'capistrano/ext/multistage'

## Generated with 'brightbox' on Thu Apr 21 11:12:49 +0100 2011
gem 'brightbox', '>=2.3.8'
require 'brightbox/recipes'
require 'brightbox/passenger'

# The name of your application.  Used for deployment directory and filenames
# and Apache configs. Should be unique on the Brightbox
set :application, "mangrove-validation"


# Target directory for the application on the web and app servers.
set(:deploy_to) { File.join("", "home", user, application) }

# URL of your source repository. By default this will just upload
# the local directory.  You should probably change this if you use
# another repository, like git or subversion.

#set :deploy_via, :copy
set :repository, "git@github.com:unepwcmc/mangrove-validation.git"

set :scm, :git
set :branch, "master"
set :scm_username, "unepwcmc-read"
set :git_enable_submodules, 1
default_run_options[:pty] = true # Must be set for the password prompt from git to work

## Dependencies
# Set the commands and gems that your application requires. e.g.
# depend :remote, :gem, "will_paginate", ">=2.2.2"
# depend :remote, :command, "brightbox"
#
# Specify your specific Rails version if it is not vendored
#depend :remote, :gem, "rails", "=2.3.8"
#depend :remote, :gem, "authlogic", "=2.1.4"
#depend :remote, :gem, "faker", "=0.9.5"
#depend :remote, :gem, "hashie", "=0.2.0"
#depend :remote, :gem, "pg", "=0.11.0"

## Local Shared Area
# These are the list of files and directories that you want
# to share between the releases of your application on a particular
# server. It uses the same shared area as the log files.
#
# So if you have an 'upload' directory in public, add 'public/upload'
# to the :local_shared_dirs array.
# If you want to share the database.yml add 'config/database.yml'
# to the :local_shared_files array.
#
# The shared area is prepared with 'deploy:setup' and all the shared
# items are symlinked in when the code is updated.
set :local_shared_files, %w(config/database.yml)
set :local_shared_dirs, %w(public/system)

task :setup_production_database_configuration do
  the_host = Capistrano::CLI.ui.ask("Database IP address: ")
  database_name = Capistrano::CLI.ui.ask("Database name: ")
  database_user = Capistrano::CLI.ui.ask("Database username: ")
  pg_password = Capistrano::CLI.password_prompt("Database user password: ")
  require 'yaml'
  spec = { "production" => {
    "adapter" => "postgresql",
    "database" => database_name,
    "username" => database_user,
    "host" => the_host,
    "password" => pg_password }}
    run "mkdir -p #{shared_path}/config"
    put(spec.to_yaml, "#{shared_path}/config/database.yml")
end
after "deploy:setup", :setup_production_database_configuration
