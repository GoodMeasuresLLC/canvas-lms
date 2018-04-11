# Canvas Upgrade Notes

## Connect to all the servers

Use csshx to connect to all the servers so you can run the same commands.

Example

`csshx production-cavnas production-cavnas-queue`

## System Upgrades

### Software packages

Some new gem versions require new libraries to compile:

`sudo apt-get -y install automake bison flex g++ git libboost1.55-all-dev libevent-dev libssl-dev libtool make pkg-config`

### Node.js

We had installed a 0.12 version of node.  We should have installed a 6.x version.
With the new canvas version, some of the node modules fail under 0.12

```
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs
npm rebuild node-sass
```

### New Bundler

This may change for each release.

`gem install bundler -v 1.13.3`

## Upgrade

Execute all these in `/mnt/canvas`.

### Latest code

This is our git up command

`git pull --rebase`

### Upgrade Gems and Modules

Remove Gemfile.lock, this allows bundle install to proceed

`rm Gemfile.lock`

Get new gems

`bundle install --path vendor/bundle`

Get new node packages

`npm install`

### Asset Compilation

`bundle exec rake canvas:compile_assets`

### Migrate

`bundle exec rake db:migrate`

### Restart

The restarts may need to be specific to each server.  For instance, don't start
puma on the delayed job servers and vice-versa.

Puma Restart (production-canvas)

```
sudo kill -9 $(cat /mnt/canvas/tmp/pids/puma.pid)
bundle exec puma -C config/puma.rb -d
```

Delayed Job Restart (production-queue)

`./script/delayed_job restart`

## All in one instructions (except for restart)

Might work, might not!

```
sudo apt-get -y install automake bison flex g++ git libboost1.55-all-dev libevent-dev libssl-dev libtool make pkg-config
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs
npm rebuild node-sass
gem install bundler -v 1.13.3
git pull --rebase
rm Gemfile.lock
bundle install --path vendor/bundle
npm install
bundle exec rake canvas:compile_assets
bundle exec rake db:migrate
```

Now, restart your servers (individual restarts, see above)

# Other Notes

This might fix asset problems locally

```
bundle exec rake brand_configs:generate_and_upload_all
```

This might also help locally

```
gem install bundler -v 1.13.3
bundler _1.13.3_ install --path vendor/bundle
bundler _1.13.3_ exec rails s --port 4000
```
