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

    class Instance
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
      @ec2 ||= RightAws::Ec2.new(access_key_id, secret_access_key, :logger => Logger.new("/dev/null"))
    end
  end
end
