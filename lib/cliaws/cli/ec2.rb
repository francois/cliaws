require "thor"
require "cliaws"

module Cliaws
	module Cli
		class Ec2 < Thor
			map ["-h", "--help"] => :help

			map ["describe-instances"] => :list
			desc "list", <<EOD
Returns a list of all known EC2 instances
EOD
			method_options :yaml => :boolean
			def list
				instances = Cliaws.ec2.list
				if options[:yaml] then
					puts instances.map {|i| i.raw_data}.to_yaml
				else
					printf "%-10s %-50s %-12s %s\n", "ID", "DNS Name", "State", "Groups"
					printf "-"*120
					print "\n"
					instances.each do |instance|
						printf "%-10s %-50s %-12s %s\n", instance.instance_id, instance.public_dns_name, instance.state, instance.groups.join(", ")
					end
				end
			end

			map ["launch"] => :run
			desc "run AMI", <<EOD
Launches one or more instances.  Only one group may be specified at this time.
EOD
			method_options :count => 1, :type => "m1.small", :keypair => :required, :group => :optional
			def run(ami)
				instances = Cliaws.ec2.run(ami, :type => options[:type], :count => options[:count], :keypair => options[:keypair], :groups => options[:group])
				result = {"Started" => instances.map {|i| i.instance_id}}
				puts result.to_yaml
			end

			desc "terminate INSTANCE_ID [INSTANCE_ID...]", <<EOD
Terminates all specified instances.
EOD
			def terminate(*instance_ids)
				instances = Cliaws.ec2.terminate(instance_ids)
				result = {"Terminating" => instances.map {|i| i.instance_id}}
				puts result.to_yaml
			end

			map ["allocate-address"] => :allocate_address
			desc "allocate-address", <<EOD
Assigns an elastic IP with your account.
EOD
			def allocate_address
				address = Cliaws.ec2.allocate_address
				puts "Allocated: #{address}"
			end

			map ["deallocate-address"] => :deallocate_address
			desc "deallocate-address ADDRESS", <<EOD
Deallocates the given Elastic IP address from your account.
EOD
			def deallocate_address(address)
				Cliaws.ec2.deallocate_address(address)
				puts "Deallocated: #{address}"
			end

			map ["associate-address"] => :associate_address
			method_options :address => :required, :instance => :required
			desc "associate-address", <<EOD
Associates an address to an instance.
EOD
			def associate_address
				address  = options[:address]
				instance = options[:instance]
				Cliaws.ec2.associate_address(:address => address, :instance => instance)
				puts "Associated:\n  #{instance}: #{address.inspect}"
			end

			map ["disassociate-address"] => :disassociate_address
			desc "disassociate-address ADDRESS", <<EOD
Disassociates an address from an instance.
EOD
			def disassociate_address(address)
				address = options[:address]
				Cliaws.ec2.disassociate_address(address)
				puts "Disassociated: #{address}"
			end

			map ["describe-addresses"] => :describe_addresses
			desc "describe-addresses", <<EOD
Returns a YAML representation of all Elastic IP addresses associated with this account.
EOD
			def describe_addresses
				puts Cliaws.ec2.describe_addresses.to_yaml
			end
		end
	end
end
