#!/usr/bin/env puma

directory '/mnt/canvas'
rackup "/mnt/canvas/config.ru"
environment 'staging'

pidfile "/mnt/canvas/tmp/pids/puma.pid"
state_path "/mnt/canvasd/tmp/pids/puma.state"
stdout_redirect '/mnt/canvas/log/puma.error.log', '/mnt/code/current/log/puma.access.log', true


threads 3,3

bind 'unix:///mnt/canvas/tmp/sockets/code-puma.sock'

workers 2



prune_bundler


on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "/mnt/code/current/Gemfile"
end


