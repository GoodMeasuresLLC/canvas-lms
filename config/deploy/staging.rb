require 'pry'
require 'aws-sdk'
set :stage, :staging
set :puma_env, :staging
set :newrelic_env, fetch(:stage, fetch(:rack_env, fetch(:rails_env, 'staging')))


set :home_url, "http://code.staging-goodmeasures.com"
set :domain, "staging-goodmeasures.com"
set :rails_env, "staging"

vpc = Aws::EC2::Vpc.new('vpc-0f490b69')

instances = vpc.instances.each_with_object([]){|instance,array| array << {"server" => instance}.merge(instance.tags.map{|tag| {tag.key => tag.value}}.inject(:merge))}

nat_dns_name = instances.select{|instance| instance["Name"] == 'staging-nat'}.first["server"].public_dns_name

set :ssh_options, {
  forward_agent: true,
  auth_methods: %w(publickey),
  proxy: Net::SSH::Proxy::Command.new("ssh ec2-user@#{nat_dns_name} -W %h:%p"),
  paranoid: false
}
deploy_instances = instances.select{|instance| instance['capistrano_roles'] && instance['application'] == "canvas" && instance['environment'] == "staging-vpc" && instance['server'].state.name == "running"}

deploy_instances.each do |instance|
  roles = instance['capistrano_roles'].split(/,|\|/)
  server "#{instance['server'].private_ip_address}", user: 'ubuntu', roles: roles
end

# set :aws_autoscale_instance_size, 'm3.large'

# autoscale 'staging-canvas-application-asg', user: 'ubuntu', roles: [:app]

