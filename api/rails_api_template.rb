require 'fileutils'
require 'byebug'

# Add the current directory to the path Thor uses
# to look up files
def source_paths
  Array(super) + 
    [File.expand_path(File.dirname(__FILE__)), "/Users/vincentdaubry/Documents/Projets/templates/app/views/layouts"]
end

# We'll be building the Gemfile from scratch
remove_file "Gemfile"
run "touch Gemfile"

add_source 'https://rubygems.org'


inject_into_file 'Gemfile', :after => "'https://rubygems.org'" do
  "\n\nruby '2.3.0'"
end

gem 'rails'
gem 'rails-api'
gem 'active_model_serializers'
gem 'puma'
gem 'pg'
gem 'newrelic_rpm'
gem 'kaminari'
gem 'redis'
gem 'bcrypt'
gem 'sentry-raven'
gem 'sidekiq'
gem 'lograge'
gem 'aws-sdk'


gem_group :development, :test do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
end

gem_group :development do
  gem 'dotenv-rails'
  gem 'rack-mini-profiler'
  gem 'bullet'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'derailed'
  gem 'stackprof'
end

gem_group :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'factory_girl_rails'
  gem 'webmock'
  gem 'fakeredis'
  gem 'vcr'
end

gem_group :production do
  gem 'rails_12factor'
end

remove_file ".gitignore"
copy_file ".gitignore"
copy_file ".env"
copy_file "Procfile"

remove_dir "test"
directory "custom_test", "test"

inside 'config' do
  copy_file "puma.rb"
  remove_file "routes.rb"
  copy_file "routes_template.rb", "routes.rb"
  copy_file "newrelic.yml"
  gsub_file 'newrelic.yml', /%app_name%/, @app_name
    
  inside 'initializers' do
    copy_file "redis.rb"
    copy_file "sentry.rb"
  end
end

inside 'app' do
  empty_directory "classes"
  inside 'classes' do
    directory "presenters"
    directory "user_services"
    empty_directory "workers"
    directory "validators"
    empty_directory "builders"
  end
  
  ["custom_controllers", 
   "custom_models"].each do |path|
    original_path = path.gsub("custom_", "") #Custom template folders don't override rails generator folders (ex: rails/generators/rails/app/templates/app/views/)
    remove_dir original_path
    directory path, original_path
  end
  
  directory "mailers"
  directory "serializers"
end

after_bundle do
  run "spring stop"
  
  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"  
  
  #Add pessimistic constraint operator (~>) to all gems in your Gemfile, see : https://github.com/joonty/pessimize
  run "pessimize"
  
  run "DISABLE_SPRING=1 rails generate rspec:install"
  
  inside 'spec' do
    empty_directory "classes"
    inside 'classes' do
      empty_directory "validators"
      empty_directory "presenters"
      empty_directory "workers"
      empty_directory "serializers"
      empty_directory "builders"
    end
    
    empty_directory "factories"
    empty_directory "jobs"
    
    remove_file "spec_helper.rb"
    copy_file "spec_helper.rb"
    remove_file "rails_helper.rb"
    copy_file "rails_helper.rb"
    
    directory "controllers"
    directory "models"
    directory "factories"
  end
  
  inside 'config' do
    copy_file "locales/fr.yml"
    
    remove_file "application.rb"
    copy_file "application_template.rb", "application.rb"
    gsub_file 'application.rb', /%app_name%/, @app_name.capitalize
    
    inside 'environments' do
      remove_file "development.rb"
      copy_file "development_template.rb", "development.rb"
      
      remove_file "test.rb"
      copy_file "test_template.rb", "test.rb"
      
      remove_file "production.rb"
      copy_file "production_template.rb", "production.rb"
    end
  end
  
  run "createuser --superuser #{app_name}"
  rake "db:create"
  run "DISABLE_SPRING=1 rails generate migration create_users"
  user_migration_file = Dir.glob("db/migrate/*.rb").first
  remove_file user_migration_file
  copy_file "db/migrate/create_users.rb", user_migration_file
  rake "db:migrate"
  
  append_to_file 'db/seeds.rb', 'User.destroy_all\n'
  append_to_file 'db/seeds.rb', 'User.create!(email: "vdaubry@gmail.com", password: "azerty", token: "azerty", admin: true)'
  rake "db:seed"
  
  rake "db:create", env: :test
  rake "db:migrate", env: :test
  
  #capistrano
  run "DISABLE_SPRING=1 bundle exec cap install"
  inside 'config' do
    remove_file "deploy.rb"
    run "rm -Rf deploy"
    copy_file "deploy.rb"
    gsub_file 'deploy.rb', /%app_name%/, @app_name
    directory "deploy"
  end

  #github
  #git add remote origin "git@github.com:vdaubry/#{app_name}.git"
  
  run "rspec"
  
  git add: "."
  git commit: "-a -m 'Setup app'"
end