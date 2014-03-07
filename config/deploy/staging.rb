# Direct because cloud flare blocks ssh
web_servers = ["staging.hashbros.co.in"]
web_servers.each do |server|
	role :web, server 
	role :db, server, primary: true
end

set :deploy_to, "/var/www/Hashbros"
set :rails_env, 'staging'
set :branch, 'master'