require 'spotter'

namespace :spotter do
  desc 'test amazon client connection'
  task :test_client do
    puts ENV['AWS_ACCESS_KEY_ID']
    puts ENV['AWS_SECRET_ACCESS_KEY']
    puts ENV['AWS_REGION']
    client = Spotter::Amazon::Ec2Client.get
    client.describe_instances.reservations.each { |i| puts i}
    # client.instances.inject({}) { |m, i| m[i.id] = i.status; m }
  end
end