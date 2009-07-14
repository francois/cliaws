require "thor"
require "cliaws"

module Cliaws
	module Cli
		class S3 < Thor
			map ["-h", "--help"] => :help

      desc "buckets", <<EOD
Returns a list of bucket names.
EOD
      def buckets
        puts Cliaws.s3.buckets.map {|bucket| bucket.name}
      end

      desc "create BUCKET", <<EOD
Creates a new bucket.  If the bucket already exists, this command returns 1.
EOD
      def create(name)
        Cliaws.s3.bucket(name, true)
      end

      desc "delete BUCKET", <<EOD
Deletes the named bucket.  Will only delete the bucket if it is empty, unless --force.
Returns 1 if the bucket did not exist.
Returns 0 if the bucket existed and was deleted.
EOD
      method_options :force => false
      def delete(name)
        bucket = Cliaws.s3.bucket(name, false)
        exit 1 if bucket.nil?
        bucket.delete(options[:force])
      end

			desc "url S3_OBJECT_PATH", <<EOD
Returns a signed, private, URL to the given S3 object that is valid for 24 hours.
EOD
			def url(s3_object)
				puts Cliaws.s3.url(s3_object)
			rescue Cliaws::S3::UnknownBucket
				abort "Could not find bucket named #{$!.bucket_name}"
			end

			desc "list [S3_OBJECT_PATH_PREFIX]", <<EOD
Lists all S3 objects that start with the given string.

EXAMPLES

If the bucket named "vacation" contains the files "movies/arrival.mp4",
"movies/at_the_ball.mp4" and "photos/johnson_and_us.jpg", then:

$ clis3 list vacation/movies
movies/arrival.mp4
movies/at_the_ball.mp4

$ clis3 list vacation
movies/arrival.mp4
movies/at_the_ball.mp4
photos/johnson_and_us.jpg

$ clis3 list vacation/p
photos/johnson_and_us.jpg
EOD
			def list(prefix="")
				puts Cliaws.s3.list(prefix)
			rescue Cliaws::S3::UnknownBucket
				abort "Could not find bucket named #{$!.bucket_name}"
			end

			desc "touch S3_OBJECT_PATH", <<EOD
Creates or OVERWRITES a named file at the specified path.

WARNING: If the file already exists, IT WILL BE OVERWRITTEN with no content.
EOD
			def touch(s3_object)
				Cliaws.s3.put("", s3_object)
			rescue Cliaws::S3::UnknownBucket
				abort "Could not find bucket named #{$!.bucket_name}"
			end

			desc "put [LOCAL_FILE [LOCAL_FILE ...]] S3_PATH", <<EOD
Puts one or more named local files, or a simple string, to a path.

This method has the same interface as cp(1).

EXAMPLES

$ clis3 put --data "123 Grand St / Old Orchard Beach" vacation/2009/where.txt
$ clis3 put photos/phil_johnson.jpg vacation/2009/phil_johnson.jpg
$ clis3 put photos/peter.jpg photos/sarah.jpg vacation/2009/photos/hosts
$ clis3 put movies vacation/2009/movies
EOD
      method_options :data => :optional
			def put(*args)
				paths = args
				s3_object = paths.pop

				single_put_mapper = lambda do |source, s3_path|
					raise ArgumentError, "Writing directly from STDIN is forbidden when STDIN's size is unknown.  The RightAws library will write a zero-byte file to Amazon's servers." unless source.respond_to?(:lstat) || source.respond_to?(:size)
					s3_path
				end

				multi_put_mapper  = lambda do |source, s3_path|
					if source.respond_to?(:path) then
						File.join(s3_path, File.basename(source.path))
					else
						raise ArgumentError, "Cannot write to a directory when one or more sources are not files: #{source.inspect}"
					end
				end

				if options[:data] && !paths.empty? then
					raise ArgumentError, "Cannot specify both --data and filename(s) to send."
				elsif options[:data] then
					sources = [StringIO.new(options[:data])]
					mapper  = single_put_mapper
				elsif paths == ["-"] then
					sources = [STDIN]
					mapper  = single_put_mapper
				else
					targets = paths.map {|filename| filename.to_s}
					case targets.length
					when 0
						sources = [STDIN]
						mapper  = single_put_mapper
					when 1
						sources = targets.map {|target| File.open(target, "rb")}
						mapper  = single_put_mapper
					else
						sources = targets.map {|target| File.open(target, "rb")}
						mapper  = multi_put_mapper
					end
				end

				sources.each do |source|
					target = mapper.call(source, s3_object)
					if source.respond_to?(:path) then
						puts "#{source.path} => #{target}"
					else
						puts "STDIN => #{target}"
					end

					Cliaws.s3.put(source, target)
				end
			rescue Cliaws::S3::UnknownBucket
				abort "Could not find bucket named #{$!.bucket_name}"
			end

			desc "rm S3_OBJECT [S3_OBJECT ...]", <<EOD
Deletes one or more S3 objects.

Does not accept wildcards: each path to delete must be named individually.
EOD
			def rm(*paths)
				paths.each do |path|
					puts "rm #{path}"
					Cliaws.s3.rm(path)
				end
			rescue Cliaws::S3::UnknownBucket
				abort "Could not find bucket named #{$!.bucket_name}"
			end

			desc "cat S3_OBJECT", <<EOD
Prints the contents of the named object to STDOUT.
A single new line (\n) will be appended to the output.
EOD
			def cat(s3_object)
				print Cliaws.s3.get(s3_object, STDOUT)
				puts
			rescue Cliaws::S3::UnknownBucket
				abort "Could not find bucket named #{$!.bucket_name}"
			end

			desc "get S3_OBJECT [LOCAL_FILE]", <<EOD
Returns the raw contents of the named object.

If LOCAL_FILE is unspecified, it will default to STDOUT.
EOD
			def get(s3_object, local_path=nil)
				out = if local_path then
								File.open(local_path, "wb")
							else
								STDOUT
							end

				Cliaws.s3.get(s3_object, out)
			rescue Cliaws::S3::UnknownBucket
				abort "Could not find bucket named #{$!.bucket_name}"
			end

			desc "head S3_OBJECT", "Returns a YAML representation of meta data that Amazon keeps about the named object"
			def head(s3_object)
				puts Cliaws.s3.head(s3_object).to_yaml
			rescue Cliaws::S3::UnknownBucket
				abort "Could not find bucket named #{$!.bucket_name}"
			end

      desc "grants BUCKET|KEY", <<EOD
Returns a YAML representation of grants assigned to a bucket or key.
EOD
      def grants(thing)
        result = Cliaws.s3.grants(thing).inject(Hash.new) do |memo, grant|
          memo[grant.to_s] = grant.perms
          memo
        end

        result = {thing => result}.to_yaml
        puts result
      end

      desc "grant BUCKET|KEY (ID|EMAIL|AllUsers|AuthenticatedUsers) PERMISSION [PERMISSION...]", <<EOD
Grants one or more permissions to a user or group.  Returns the new permissions on the bucket or key as YAML.

Examples
cliec2 grant my_awesome_bucket/some/key AllUsers READ
cliec2 grant my_private_bucket friend@somewhere.com full-control
cliec2 grant movies a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9 read WRITE
EOD
      def grant(thing, who, *permissions)
        who = case who
              when /^AllUsers$/i
                "http://acs.amazonaws.com/groups/global/AllUsers"
              when /^AuthenticatedUsers$/i
                "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
              else
                who
              end
        Cliaws.s3.grant(thing, who => permissions.map {|perm| perm.gsub('_', '-')})
        grants(thing)
      end

      desc "revoke BUCKET|KEY (ID|EMAIL|AllUsers|AuthenticatedUsers) [PERMISSION [PERMISSION...]]", <<EOD
Revokes one or more permissions to a user or group.  If no permissions are given, all grants are dropped.  Returns the new permissions on the bucket or key as YAML.

Examples
cliec2 revoke my_awesome_bucket/some/key AllUsers
cliec2 revoke my_awesome_bucket/some/key AllUsers READ
cliec2 revoke my_private_bucket friend@somewhere.com full-control
cliec2 revoke movies a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9 read WRITE
EOD
      def revoke(thing, who, *permissions)
        who = case who
              when /^AllUsers$/i
                "http://acs.amazonaws.com/groups/global/AllUsers"
              when /^AuthenticatedUsers$/i
                "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
              else
                who
              end
        Cliaws.s3.grant(thing, who => permissions.map {|perm| perm.gsub('_', '-')})
        grants(thing)
      end
		end
	end
end
