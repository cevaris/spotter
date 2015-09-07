module Spotter
  module Amazon
    class Request

      def self.types
        Spotter::Amazon::TYPES
      end

      def self.desc
        Spotter::Amazon::DESCRIPTIONS
      end

      def self.zones
        client = Spotter::Amazon::Client.ec2
        client.describe_availability_zones.availability_zones.map {|az| az.zone_name}
      end

      def self.random_zone
        zones.shuffle.first
      end

      def self.spot_price_history
        client = Spotter::Amazon::Client.ec2
        resp = client.describe_spot_price_history({
                # dry_run: true,
                start_time: Time.now,
                end_time: Time.now,
                instance_types: [types[:m1_small]],
                product_descriptions: [desc[:linux_unix]],
                availability_zone: random_zone,
                max_results: 5,
                next_token: '',
            })
        puts resp.inspect
      end

    end

  end
end