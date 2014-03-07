require 'new_relic/recipes'
require "capistrano/ext/multistage"
require "bundler/capistrano"
require "rvm/capistrano"
require "whenever/capistrano"

set :application, "Hashbros"
set :current_path, "/var/www/Hashbros/current"
set :shared_path, "/var/www/Hashbros/shared"
set :stages, ["production", "staging"]
set :default_stage, "production"

default_run_options[:pty] = true

set :scm, :git
set :repository,  "git@github.com:Sovietaced/Hashbros.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "deployer"
set :use_sudo, false

# Only run cron jobs on app nodes
set :whenever_roles, :engine

# Run migrations after deploying
after "deploy:update_code", "deploy:migrate"

# Restart web workers
after "deploy:update_code", "deploy:puma"

# Alert New Relic
after "deploy:update", "newrelic:notice_deployment"

# After flush the cache
after "deploy", "deploy:flush_cache"

# keep only the last 5 releases
after "deploy", "deploy:cleanup"

namespace :deploy do 
  desc "Flushes Memcached"
  task :flush_cache, :roles => :web do
    run("cd #{current_path} && RAILS_ENV=#{rails_env} rake memcached:flush")
  end

  task :puma, :roles => :web do
    run("sudo service puma restart")
  end

  # Only precompile modified assets
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if releases.length <= 1 || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end

