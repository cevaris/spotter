require 'aws-sdk'

module Spotter
  module Amazon
    class Ec2Client

      #@return [Aws::EC2::Client]
      def self.get
        Aws::EC2::Client.new
      end # get

    end
  end
end