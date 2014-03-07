# Direct because cloud flare blocks ssh
web_servers = ["web-2.hashbros.co.in", "web-3.hashbros.co.in"]
web_servers.each do |server|
	role :web, server
	role :app, server
	role :db, server, primary: true
end

app_servers = ["worker-1.hashbros.co.in"]
app_servers.each do |server|
	role :engine, server, primary: true
end


set :deploy_to, "/var/www/Hashbros"
set :rails_env, 'production'
set :branch, 'master'
