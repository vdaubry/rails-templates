require 'fileutils'
require 'byebug'
require 'yaml'

# Add the current directory to the path Thor uses
# to look up files
def source_paths
  Array(super) + 
    [File.expand_path(File.dirname(__FILE__))]
end

#We'll be building the Gemfile from scratch
remove_file "Gemfile"
run "touch Gemfile"

add_source 'https://rubygems.org'


inject_into_file 'Gemfile', :after => "'https://rubygems.org'" do
  "\n\nruby '3.0.0'"
end

gem 'rails', '>= 6.0'

gem 'pg'
gem 'puma'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'coffee-rails'
gem 'turbolinks'
gem 'newrelic_rpm'
gem 'kaminari'
gem 'redis'
gem 'bcrypt'
gem 'sidekiq'
gem 'lograge'
gem 'administrate'
gem 'webpacker'
gem 'bootsnap', '>= 1.4.2', require: false

#Add for performance profiling
# gem 'rack-mini-profiler'
# gem 'memory_profiler'
# gem 'flamegraph'
# gem 'stackprof'
# gem 'ruby-prof'
# gem 'benchmark-ips'
# gem 'derailed'

gem_group :development, :test do
  gem 'byebug'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
end

gem_group :development do
  gem 'web-console'
  gem 'dotenv-rails'
  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'marginalia'
end

gem_group :test do
  gem 'rspec-rails', '~> 4.0.0.rc1'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'factory_bot_rails'
  gem 'webmock'
  gem 'fakeredis'
  gem 'rails-controller-testing'
end

gem_group :assets do
  gem 'uglifier'
end

gem_group :production do
  gem 'rails_12factor'
  gem 'sentry-raven'
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
    directory "builders"
    directory "presenters"
    directory "validators"
    directory "user_services"
    empty_directory "workers"
    empty_directory "builders"

    copy_file "callback.rb"
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
  copy_file "assets/javascripts/google_analytics.js.coffee"
  
  directory "mailers"
  directory "serializers"
  directory "jobs"
end

after_bundle do
  run "spring stop"
  
  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"  
  
  run "DISABLE_SPRING=1 rails generate rspec:install"
  
  inside 'spec' do
    empty_directory "classes"
    inside 'classes' do
      empty_directory "presenters"
      empty_directory "workers"
      empty_directory "serializers"
      empty_directory "validators"
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
    directory "helpers"
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
  
  append_to_file 'db/seeds.rb' do
    'User.destroy_all'
    "User.create!("\
      "email: 'vdaubry@gmail.com',"\
      "password: 'azerty',"\
      "admin: true,"\
      "token: SecureRandom.uuid,"\
      "refresh_token: SecureRandom.uuid"\
    ")"
  end
  rake "db:seed"
  
  rake "db:create", env: :test
  rake "db:migrate", env: :test
  
  remove_file "app/controllers/admin/users_controller.rb" #skip is ignored by administrate when generating user_controller...
  run "DISABLE_SPRING=1 rails generate administrate:install --skip"
  remove_file "app/controllers/admin/users_controller.rb"
  copy_file "app/custom_controllers/admin/users_controller.rb", "app/controllers/admin/users_controller.rb"
  copy_file "app/dashboards/user_dashboard.rb", "app/dashboards/user_dashboard.rb"

  #Add pessimistic constraint operator (~>) to all gems in your Gemfile, see : https://github.com/joonty/pessimize
  run "pessimize"
  
  #capistrano
  # run "DISABLE_SPRING=1 bundle exec cap install"
  # inside 'config' do
  #   remove_file "deploy.rb"
  #   run "rm -Rf deploy"
  #   copy_file "deploy.rb"
  #   gsub_file 'deploy.rb', /%app_name%/, @app_name
  #   directory "deploy"
  # end
  
  run "rspec"
  
  git add: "."
  git commit: "-a -m 'Setup app'"
  
  directory "../scripts", "scripts"
  run "chmod +x ./scripts/*"
  
  # #github
  # run "git remote add origin git@github.com:vdaubry/#{@app_name}.git"
  
  # #heroku
  # run "git remote add production git@heroku.com:#{@app_name}.git"
  # run "heroku pg:backups schedule DATABASE_URL --at '02:00 Europe/Paris' -a #{@app_name}"
  
  # #heroku run rake task buildpack
  # run "heroku buildpacks:set https://github.com/heroku/heroku-buildpack-ruby"
  # run "heroku buildpacks:add https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks"
  # run "heroku config:set DEPLOY_TASKS='db:migrate'"
end