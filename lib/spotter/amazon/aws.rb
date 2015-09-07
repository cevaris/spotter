require 'aws-sdk'

module Spotter
  module Amazon

    AWS_ACCESS_KEY_ID='AWS_ACCESS_KEY_ID'
    AWS_SECRET_ACCESS_KEY='AWS_SECRET_ACCESS_KEY'
    AWS_REGION='AWS_REGION'

    raise 'Missing AWS_ACCESS_KEY_ID Environment variable' unless ENV.include? AWS_ACCESS_KEY_ID
    raise 'Missing AWS_SECRET_ACCESS_KEY Environment variable' unless ENV.include? AWS_SECRET_ACCESS_KEY
    raise 'Missing AWS_REGION Environment variable' unless ENV.include? AWS_REGION

    aws_region = ENV[AWS_REGION]
    aws_id = ENV[AWS_ACCESS_KEY_ID]
    aws_secret = ENV[AWS_SECRET_ACCESS_KEY]
    aws_creds = Aws::Credentials.new(aws_id, aws_secret)

    Aws.config.update({region: aws_region, credentials: aws_creds})

    require 'spotter/amazon/ec2_client'

  end
end