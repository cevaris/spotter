require 'spotter'

namespace :spotter do
  desc 'test amazon client connection'
  task :test_client do
    puts ENV['AWS_ACCESS_KEY_ID']
    puts ENV['AWS_SECRET_ACCESS_KEY']
    puts ENV['AWS_REGION']
    client = Spotter::Amazon::Client.ec2
    puts client.describe_instances.inspect
  end
end