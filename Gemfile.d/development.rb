group :development do
  gem 'guard', '2.14.0'
    gem 'listen', '3.1.5', require: false
      gem 'rb-inotify', '0.9.7', require: false
      gem 'rb-fsevent', '0.9.8', require: false
  gem 'colorize', '0.8.1', require: false
  gem 'letter_opener', '1.4.1'
  gem 'spring', '2.0.0'
  gem 'spring-commands-rspec', '1.0.4'
  #capistrano deploys

  gem 'elbas'
  gem 'capistrano', :require => false
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rbenv'
  gem 'capistrano3-puma'
  gem 'capistrano-maintenance', :require => false
  gem 'slackistrano', :require => false
  # Option to DISABLE_RUBY_DEBUGGING is helpful IDE-based debugging.
  # The ruby debug gems conflict with the IDE-based debugger gem.
  # Set this option in your dev environment to disable.
  unless ENV['DISABLE_RUBY_DEBUGGING']
    gem 'byebug', '9.0.6', platform: :mri
  end
end
