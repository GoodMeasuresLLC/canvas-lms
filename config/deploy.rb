require 'aws-sdk'
require 'net/ssh/proxy/command'

# set :bugsnag_api_key, "a0df3ca22f9c2ce27aca7a272e896724"

set :application, 'canvas'
set :repo_url, 'git@github.com:GoodMeasuresLLC/canvas-lms.git'
set :repo, 'git@github.com:GoodMeasuresLLC/canvas-lms.git'
set :deploy_to, '/mnt/canvas'
set :scm, :git
set :format, :pretty
set :log_level, :debug
set :user, "ubuntu"
set :runner, "ubuntu"
set :use_sudo, true
set :pty, true
set :git_enable_submodules, 1
set :tmp_dir, '/home/ubuntu/tmp'
set :update_deploy_timestamp_tags, true
set :assets_roles, [:app]   # Defaults to [:web]
set :branch, `git branch`.match(/\* (\S+)\s/m)[1]

set :ssh_options, {
    forward_agent: true,
    auth_methods: %w(publickey)
}

set :maintenance_template_path, "./public/maintenance.html.erb"
#puma configs
set :puma_threads, [3, 3]
set :puma_workers, 2
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, false
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_prune_bundler, true
### CLEANUP RELEASES
# Capistrano has the ability to delete old release directories on the servers during deployment. The only
# problem with doing it this way is that it takes f-o-r-e-v-e-r. Instead we use a crontask on each server
# that cleans the releases automatically. Here we tell capistrano to leave 100 releases on the server. It
# essentially will never try to cleanup releases automatically.
set :keep_releases, 5 # this is how we tell capistrano to ignore the release cleanup and let the crontask catch it

### DELAYED JOB
# this line passes arguments to the ./script/delayed_job script. Here it says we need 3 workers.
set :delayed_job_args, "-n 3"

### for slack integration
set :slack_webhook, "https://hooks.slack.com/services/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"
set :slack_channel, "#deploy"
set :slack_username, "Slackistrano"
set :slack_run_starting, true
set :slack_run_finished, true
set :slack_run_failed, true

### for capistrano-rbenv
set :rbenv_type, :system # or :user, depends on your rbenv setup
set :rbenv_ruby, '2.3.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value
set :default_env, { path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" }

# dirs we want symlinking to shared

set :linked_dirs, %w{bin log tmp/pids tmp/sockets vendor/bundle public/system}

before 'deploy:migrate', :symlink_config

task :reenable_phased_restart do
  ::Rake.application['puma:phased-restart'].reenable
end

# Elbas autoscaling shared settings
# set :aws_launch_configuration_iam_instance_profile, 'autoscaling-role'
# set :aws_launch_configuration_associate_public_ip, false

# http://railsguides.net/how-to-define-environment-variables-in-rails/
desc "Link shared files"
task :symlink_config do
  on roles(:all) do |host|
    symlinks = {
      "#{shared_path}/config" => "#{release_path}/config"
    }
    execute symlinks.map{|from, to| "ln -nfs #{from} #{to}"}.join(" && ")
  end
end


### RESTARTS
# Delayed-Job: this line uses a capistrano callback to restart delayed job. The actual definition of the restart process
# is captured in Rails.root/lib/capistrano/tasks/delayed_job.cap
#
# Nginx: the task responsible for restarting nginx is called internally on the 'restart' trigger which is part of
# capistrano's built-in lifecycle. The task definition is captured in Rails.root/lib/capistrano/tasks/restart.cap
after 'deploy:publishing', 'deploy:restart'

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
end

