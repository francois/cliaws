require "right_aws"

# Load vendor code through RubyGems
require "right_http_connection"

# Then patch it here
require File.dirname(__FILE__) + "/../../vendor/right_http_connection-1.2.1/lib/right_http_connection"

module Cliaws
  class S3
    attr_reader :access_key_id, :secret_access_key
    protected :access_key_id, :secret_access_key

    def initialize(access_key_id, secret_access_key)
      @access_key_id, @secret_access_key = access_key_id, secret_access_key
    end

    def url(full_name)
      bucket_name, path = full_name.split("/", 2)
      bucket = s3g.bucket(bucket_name, false)
      bucket.get(path)
    end

    def list(glob)
      bucket, path = bucket_and_key_name(glob)
      options = Hash.new
      options["prefix"] = path unless path.nil? || path.empty?
      bucket.keys(options).map {|b| b.full_name}
    end

    def get(s3_object, dest=nil)
      bucket, keyname = bucket_and_key_name(s3_object)
      if dest.nil? then
        bucket.get(keyname)
      else
        dest.write(bucket.get(keyname))
      end
    end

    def head(s3_object)
      bucket, keyname = bucket_and_key_name(s3_object)
      key = bucket.key(keyname, true)
      headers = key.headers
      puts headers.merge(key.meta_headers).to_yaml
    end

    def put(source, s3_object, create=true)
      bucket, keyname = bucket_and_key_name(s3_object, create)
      bucket.put(keyname, source)
    end

    def rm(s3_object)
      bucket, keyname = bucket_and_key_name(s3_object)
      bucket.key(keyname).delete
    end

    protected
    def bucket_and_key_name(full_name, create=true)
      bucket_name, path = full_name.split("/", 2)
      bucket = s3.bucket(bucket_name, create)
      raise UnknownBucket.new(bucket_name) unless bucket
      [bucket, path]
    end

    def s3
      @s3 ||= RightAws::S3.new(access_key_id, secret_access_key, :logger => Logger.new("/dev/null"))
    end

    def s3g
      @s3i ||= RightAws::S3Generator.new(access_key_id, secret_access_key, :logger => Logger.new("/dev/null"))
    end

    class UnknownBucket < ArgumentError
      attr_reader :bucket_name

      def initialize(bucket_name)
        super("Bucket #{bucket_name.inspect} could not be found")
        @bucket_name = bucket_name
      end
    end
  end
end
