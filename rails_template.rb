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

gem 'rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
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
  gem 'pry-rails'
end

gem_group :development do
  gem 'dotenv-rails'
  gem 'rack-mini-profiler'
  gem 'quiet_assets'
  gem 'bullet'
  gem 'web-console'
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
  gem 'puma'
end

remove_file ".gitignore"
copy_file ".gitignore"
copy_file ".env"
copy_file "Procfile"

remove_dir "test"

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
    empty_directory "presenters"
    empty_directory "workers"
    empty_directory "serializers"
    empty_directory "validators"
    empty_directory "builders"
  end
  
  ["custom_views", 
   "custom_controllers", 
   "custom_models", 
   "custom_helpers"].each do |path|
    original_path = path.gsub("custom_", "") #Custom template folders don't override rails generator folders (ex: rails/generators/rails/app/templates/app/views/)
    remove_dir original_path
    directory path, original_path
  end
  gsub_file 'views/layouts/application.html.erb', /app_name/, @app_name
  
  copy_file "assets/stylesheets/landing-page.css"
  copy_file "assets/stylesheets/signin.css"
end

after_bundle do
  run "spring stop"
  
  generate 'rspec:install'
  
  inside 'spec' do
    empty_directory "classes"
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
  
  inside 'config/environments' do
    remove_file "development.rb"
    copy_file "development_template.rb", "development.rb"
    
    remove_file "test.rb"
    copy_file "test_template.rb", "test.rb"
    
    remove_file "production.rb"
    copy_file "production_template.rb", "production.rb"
  end
  
  run "createuser --superuser #{app_name}"
  rake "db:create"
  generate "migration", "create_users"
  user_migration_file = Dir.glob("db/migrate/*.rb").first
  remove_file user_migration_file
  copy_file "db/migrate/create_users.rb", user_migration_file
  rake "db:migrate"
  
  append_to_file 'db/seeds.rb', 'User.create!(email: "vdaubry@gmail.com", password: "azerty")'
  
  rake "db:create", env: :test
  rake "db:migrate", env: :test
  run "rspec"
  
  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"
end