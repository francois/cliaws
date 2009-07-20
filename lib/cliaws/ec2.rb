require "right_aws"

module Cliaws
  class Ec2
    attr_reader :access_key_id, :secret_access_key
    protected :access_key_id, :secret_access_key

    def initialize(access_key_id, secret_access_key)
      @access_key_id, @secret_access_key = access_key_id, secret_access_key
    end

    def list
      ec2.describe_instances.map {|raw_data| Instance.new(raw_data)}
    end

    def run(ami, options={})
      raw_data = ec2.launch_instances(ami,
                           :min_count     => options[:count],
                           :max_count     => options[:count],
                           :key_name      => options[:keypair],
                           :instance_type => options[:type])
      raw_data.map {|data| Instance.new(data)}
    end

    def terminate(instance_ids)
      raw_data = ec2.terminate_instances(instance_ids)
      raw_data.map {|data| Instance.new(data)}
    end

    def allocate_address
      ec2.allocate_address
    end

    def deallocate_address(address)
      ec2.release_address(address)
    end

    def associate_address(options)
      ec2.associate_address(options[:instance], options[:address])
    end

    def disassociate_address(address)
      ec2.disassociate_address(address)
    end

    def describe_addresses
      ec2.describe_addresses.inject([]) do |memo, hash|
        memo << {"instance_id" => hash[:instance_id], "address" => hash[:public_ip]}
      end
    end

    class Instance
      attr_reader :raw_data

      def initialize(raw_data)
        @raw_data = raw_data
      end

      def running?
        @raw_data[:aws_state] == "running"
      end

      def instance_id
        @raw_data[:aws_instance_id]
      end

      def public_dns_name
        @raw_data[:dns_name]
      end

      def private_dns_name
        @raw_data[:aws_private_dns_name]
      end

      def state
        @raw_data[:aws_state]
      end

      def groups
        @raw_data[:aws_groups]
      end
    end

    protected
    def ec2
      @ec2 ||= begin
                 logger = Logger.new(STDERR)
                 logger.level = Logger::WARN
                 RightAws::Ec2.new(access_key_id, secret_access_key, :logger => logger)
               end
    end
  end
end
