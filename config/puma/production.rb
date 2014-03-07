#!/usr/bin/env puma
directory = '/var/www/Hashbros/current'
environment 'production'
daemonize true

bind "unix:///tmp/puma.sock"
pidfile "/tmp/puma.pid"
state_path "/tmp/puma.state"

threads 1, 4
workers 2
preload_app!
activate_control_app

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end