source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'bootstrap-generators', '~> 2.0', :git => 'git://github.com/decioferreira/bootstrap-generators.git'
gem 'simple_form', :git => 'git://github.com/plataformatec/simple_form.git'
gem 'underscore-rails'
gem 'cartodb-rb-client', :git => 'git://github.com/decioferreira/cartodb-rb-client.git'
gem 'RedCloth'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'rails-backbone'
gem 'devise'

#Handle background jobs
gem 'resque'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem 'brightbox'
gem 'capistrano-ext'

group :development, :test do
  # To use debugger
  gem 'ruby-debug19'#, :require => 'ruby-debug'
end

gem 'rake', '0.9.2'

gem 'rspec-rails', '~> 2.6', :group => [:development, :test]
group :test do
  gem 'capybara'
  # LocalStorage support: https://github.com/thoughtbot/capybara-webkit/pull/310
  gem 'capybara-webkit', :git => 'git://github.com/chrisfarber/capybara-webkit.git'
  gem 'headless'
  gem 'database_cleaner'

  gem 'guard-rspec'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'launchy'
end
