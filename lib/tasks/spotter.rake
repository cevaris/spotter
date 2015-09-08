require 'spotter'

namespace :spotter do

  desc 'print aws env variables'
  task :print_aws_env do
    puts ENV['AWS_ACCESS_KEY_ID']
    puts ENV['AWS_SECRET_ACCESS_KEY']
    puts ENV['AWS_REGION']
  end

  desc 'list ec2 instances'
  task :list_instances do
    client = Spotter::Amazon::Client.ec2
    puts client.describe_instances.reservations.inspect
  end

  namespace :create do
    desc 'create default spot instance'
    task :spot_instance do
      spot = Spotter::Amazon::SpotRequest.new do
        self.instance_type = Spotter::Amazon::INSTANCE_TYPES[:m3_large]
      end
      puts spot.inspect
      puts spot.submit.inspect
    end

  end

end