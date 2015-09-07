module Spotter
  module Amazon
    class Client

      #@return [Aws::EC2::Client]
      def self.ec2
        Aws::EC2::Client.new
      end

    end
  end
end