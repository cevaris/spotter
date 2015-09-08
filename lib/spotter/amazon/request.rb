module Spotter
  module Amazon
    class Request

      def self.types
        Spotter::Amazon::INSTANCE_TYPES
      end

      def self.desc
        Spotter::Amazon::DESCRIPTIONS
      end

      def self.zones
        client = Spotter::Amazon::Client.ec2
        client.describe_availability_zones.availability_zones.map { |az| az.zone_name }
      end

      def self.zone
        zones.first
      end

      def self.random_zone
        zones.shuffle.first
      end

      def self.spot_price_history(instance_type)
        client = Spotter::Amazon::Client.ec2
        client.describe_spot_price_history({
                # dry_run: true,
                start_time: Time.now - (24 * 60 * 60), # yesterday
                end_time: Time.now,
                instance_types: [instance_type],
                product_descriptions: [desc[:linux_unix]],
                # availability_zone: availability_zone,
                max_results: 10,
                next_token: '',
            })
      end

      def self.optimal_zone(instance_type)
        sph = spot_price_history(instance_type)
        if sph.spot_price_history.empty?
          raise 'No spot price history found'
        else
          sorted = sph.spot_price_history.sort_by(&:spot_price)
          sorted.first.availability_zone
        end
      end

      def self.avg_spot_price(instance_type)
        sph = spot_price_history(instance_type)
        if sph.spot_price_history.empty?
          raise 'No spot price history found'
        else
          prices = sph.spot_price_history.map { |x| x.spot_price.to_f }
          prices.inject(:+) / prices.count
        end
      end

      # def self.request_instances(count=1, availability_zone=random_zone)
      #   client = Spotter::Amazon::Client.ec2
      #   baseline = avg_spot_price
      #   spot_price = baseline * DEFAULT_SPOT_PRICE_MULTIPLIER
      #   token = "zone:#{zone},mult:#{DEFAULT_SPOT_PRICE_MULTIPLIER},nonce:#{Time.now.utc.to_i}"
      #
      #   puts "Requested zone: #{availability_zone}"
      #   puts "Baseline Price: #{baseline} Bid Price: #{spot_price}"
      #   puts "Token: #{token}"
      #
      #   resp = client.request_spot_instances({
      #           # dry_run: true,
      #           spot_price: spot_price,
      #           client_token: token,
      #           instance_count: count,
      #           spot_type: 'one-time',
      #           valid_from: (Time.now + 60).utc.iso8601,
      #           valid_until: (Time.now + 60*5).utc.iso8601,
      #           availability_zone_group: "availability_zone_group_#{zone}",
      #           # tags: [{key: 'client_token', value: token}],
      #           launch_specification: {
      #               :image_id => 'ami-d85e75b0', #Ubuntu Server 14.04 LTS (PV), SSD Volume Type
      #               :instance_type => types[:m3_medium],
      #               :key_name => 'spotter',
      #               security_group_ids: %w(default)
      #           }
      #       })
      #
      #   puts resp.inspect
      # end

    end


    class SpotRequest

      # https://aws.amazon.com/ec2/pricing/

      attr_accessor :image_id
      attr_accessor :instance_count
      attr_accessor :instance_type
      attr_accessor :security_groups
      attr_accessor :spot_type
      attr_accessor :valid_from
      attr_accessor :valid_until
      attr_accessor :zones

      def initialize(&block)
        self.valid_from = (Time.now + 60).utc.iso8601
        self.valid_until = (Time.now + 60*5).utc.iso8601
        self.instance_count = 1
        self.spot_type = SPOT_TYPES[:one_time]
        self.zones = Request.zones
        self.image_id = 'ami-d85e75b0' #Ubuntu Server 14.04 LTS (PV), SSD Volume Type
        self.instance_type = INSTANCE_TYPES[:t1_micro]
        self.security_groups = %w(default)

        instance_eval &block if block_given?
      end

      def submit
        client = Spotter::Amazon::Client.ec2

        baseline = Request.avg_spot_price(self.instance_type)
        spot_price = (baseline * DEFAULT_SPOT_PRICE_MULTIPLIER).to_s
        zone = Request.optimal_zone(self.instance_type)
        token = "zone:#{zone},mult:#{DEFAULT_SPOT_PRICE_MULTIPLIER},nonce:#{Time.now.utc.to_i}"

        puts "Requested zone: #{zone}"
        puts "Baseline Price: #{baseline} Bid Price: #{spot_price}"
        puts "Token: #{token}"
        puts "Instance Type: #{self.instance_type}"

        resp = client.request_spot_instances({
                # dry_run: true,
                spot_price: spot_price,
                client_token: token,
                instance_count: self.instance_count,
                type: self.spot_type,
                valid_from: self.valid_from,
                valid_until: self.valid_until,
                # availability_zone_group: "availability_zone_group_#{zone}",
                # tags: [{key: 'client_token', value: token}],
                launch_specification: {
                    :image_id => self.image_id, #Ubuntu Server 14.04 LTS (PV), SSD Volume Type
                    :instance_type => self.instance_type,
                    # :key_name => 'spotter',
                    security_group_ids: self.security_groups
                }
            })

        puts resp.inspect
      end


    end
  end
end

# spot m3.medium 0.0086
# demand m3.medium 0.067
# avg-spg m3.medium 0.012
# Baseline Price: 0.01 Bid Price: 0.0125


# t1.micro 0.003, 00355, 0.0044375

# m3.large, OD: 0.133, B: 0.0035, R: 0.0044375

