require "right_aws"
require "activesupport"

module Cliaws
  class S3
    def initialize(access_key_id, secret_access_key)
      @s3 = RightAws::S3.new(access_key_id, secret_access_key, :logger => Logger.new("/dev/null"))
    end

    def list(glob)
      bucket, path = bucket_and_key_name(glob)
      options = Hash.new
      options["prefix"] = path unless path.blank?
      bucket.keys(options).map(&:full_name)
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

    def put(source, s3_object)
      bucket, keyname = bucket_and_key_name(s3_object)
      bucket.put(keyname, source)
    end

    def rm(s3_object)
      bucket, keyname = bucket_and_key_name(s3_object)
      bucket.key(keyname).delete
    end

    protected
    def bucket_and_key_name(full_name)
      bucket_name, path = full_name.split("/", 2)
      bucket = @s3.bucket(bucket_name, false)
      [bucket, path]
    end
  end
end
