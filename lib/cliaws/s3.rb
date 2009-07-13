require "right_aws"

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
      headers.merge(key.meta_headers)
    end

    def put(source, s3_object, create=true)
      bucket, keyname = bucket_and_key_name(s3_object, create)
      bucket.put(keyname, source)
    end

    def rm(s3_object)
      bucket, keyname = bucket_and_key_name(s3_object)
      bucket.key(keyname).delete
    end

    def bucket(name, create=false)
      s3.bucket(name, create)
    end

    # +permissions+ is a Hash of ID|EMAIL|URL to permissions.
    # Cliaws.s3.revoke("my_awesome_bucket/some/key", "francois@teksol.info" => %w(read write))
    # Cliaws.s3.revoke("my_awesome_bucket/some/key", "francois@teksol.info" => %w()) # Drops all grants for the user
    def revoke(name, permissions)
      bucket, thing = bucket_and_thing(name)
      permissions.each do |subject, perms|
        grantee = RightAws::S3::Grantee.new(thing, subject, perms.map {|perm| perm.upcase}, :refresh)
        if perms.empty? then
          grantee.drop
        else
          grantee.revoke(*permissions)
          grantee.apply
        end
      end
    end

    # +permissions+ is a Hash of ID|EMAIL|URL to permissions.
    # Cliaws.s3.grant("my_awesome_bucket/some/key", "francois@teksol.info" => %w(read write))
    def grant(name, permissions)
      bucket, thing = bucket_and_thing(name)
      permissions.each do |subject, perms|
        RightAws::S3::Grantee.new(thing, subject, perms.map {|perm| perm.upcase}, :apply)
      end
    end

    def grants(name)
      bucket, thing = bucket_and_thing(name)
      _, grantees = RightAws::S3::Grantee.owner_and_grantees(thing)
      grantees
    end

    protected
    def bucket_and_key_name(full_name, create=true)
      bucket_name, path = full_name.split("/", 2)
      bucket = bucket(bucket_name, create)
      raise UnknownBucket.new(bucket_name) unless bucket
      [bucket, path]
    end

    def bucket_and_thing(name)
      bucket, keyname = bucket_and_key_name(name)
      thing = keyname.nil? ? bucket : bucket.key(keyname)
      [bucket, thing]
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
