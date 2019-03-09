require 'fileutils'
require 'byebug'
require 'yaml'

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
"\n\nruby '2.5.1'"
end

gem 'rails'
gem 'active_model_serializers'
gem 'puma'
gem 'pg'
gem 'newrelic_rpm'
gem 'redis'
gem 'bcrypt'
gem 'sentry-raven'
gem 'sidekiq'
gem 'lograge'
gem 'aws-sdk'

#Add for performance profiling
# gem 'rack-mini-profiler'
# gem 'memory_profiler'
# gem 'flamegraph'
# gem 'stackprof'
# gem 'ruby-prof'
# gem 'benchmark-ips'


gem_group :development, :test do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'listen', '~> 3.0.5'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem_group :development do
  gem 'dotenv-rails'
  gem 'rack-mini-profiler'
  gem 'bullet'
  #gem 'capistrano-rails'
  #gem 'capistrano-bundler'
  gem 'derailed'
  gem 'stackprof'
  gem 'letter_opener'
end

gem_group :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'factory_bot_rails'
  gem 'webmock'
  gem 'fakeredis'
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

#DB config
db_conf_file = "config/database.yml"
db_conf = YAML.load_file db_conf_file
db_conf["pool"] = "<%= ENV.fetch('RAILS_MAX_THREADS') { 5 } %>"
File.open(db_conf_file, 'w') { |f| YAML.dump(db_conf, f) }

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
  rake "db:drop db:create"
  run "DISABLE_SPRING=1 rails generate migration create_users"
  user_migration_file = Dir.glob("db/migrate/*.rb").first
  remove_file user_migration_file
  copy_file "db/migrate/create_users.rb", user_migration_file
  rake "db:migrate"
  
  append_to_file 'db/seeds.rb' do
    'User.destroy_all'
    'User.create!(email: "vdaubry@gmail.com", password: "azerty", token: "azerty", admin: true)'
  end
  rake "db:seed"
  
  rake "db:create", env: :test
  rake "db:migrate", env: :test
  
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
  
  directory "../scripts"
  
  #github
  run "git remote add origin git@github.com:vdaubry/#{@app_name}.git"
  
  # #heroku
  # run "git remote add production git@heroku.com:#{@app_name}.git"
  # run "heroku pg:backups schedule DATABASE_URL --at '02:00 Europe/Paris' -a #{@app_name}"
  
  # #heroku run rake task buildpack
  # run "heroku buildpacks:set https://github.com/heroku/heroku-buildpack-ruby"
  # run "heroku buildpacks:add https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks"
  # run "heroku config:set DEPLOY_TASKS='db:migrate'"
end