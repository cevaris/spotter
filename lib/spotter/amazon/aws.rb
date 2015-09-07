require 'aws-sdk'

module Spotter
  module Amazon

    require 'spotter/amazon/const'

    AWS_ACCESS_KEY_ID_ENV='AWS_ACCESS_KEY_ID'
    AWS_SECRET_ACCESS_KEY_ENV='AWS_SECRET_ACCESS_KEY'
    AWS_REGION_ENV='AWS_REGION'

    raise 'Missing AWS_ACCESS_KEY_ID Environment variable' unless ENV.include? AWS_ACCESS_KEY_ID_ENV
    raise 'Missing AWS_SECRET_ACCESS_KEY Environment variable' unless ENV.include? AWS_SECRET_ACCESS_KEY_ENV
    raise 'Missing AWS_REGION Environment variable' unless ENV.include? AWS_REGION_ENV

    AWS_REGION = ENV[AWS_REGION_ENV]
    AWS_ID = ENV[AWS_ACCESS_KEY_ID_ENV]
    AWS_SECRET = ENV[AWS_SECRET_ACCESS_KEY_ENV]
    AWS_CREDS = Aws::Credentials.new(AWS_ID, AWS_SECRET)

    Aws.config.update({region: AWS_REGION, credentials: AWS_CREDS})

    require 'spotter/amazon/client'
    require 'spotter/amazon/request'

  end
end