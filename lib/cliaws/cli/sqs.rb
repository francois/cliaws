require "thor"
require "cliaws"

module Cliaws
  module Cli
    class Sqs < Thor
      map  %w(-h --help -H) => :help
      map "peek" => :receive

      desc "create QUEUE_NAME", "Creates a new queue with the specified name."
      def create(queue_name)
        Cliaws.sqs.create(queue_name)
        puts "Created #{queue_name}"
      end

      desc "delete QUEUE_NAME", "Deletes the named queue."
      method_options :force => :boolean
      def delete(queue_name)
        Cliaws.sqs.delete(queue_name, options[:force])
        puts "Queue #{queue_name} deleted"
      end

      desc "list [PREFIX]", "Lists your queues, only if they match PREFIX."
      def list(prefix=nil)
        puts Cliaws.sqs.list(prefix).map {|q| q.name}
      end

      desc "size QUEUE_NAME", "Prints the number of items in the queue to STDOUT."
      def size(queue_name)
        puts Cliaws.sqs.size(queue_name)
      end

      desc "receive QUEUE_NAME", "Prints a message from the queue to STDOUT.  This is also known as peeking."
      def receive(queue_name)
        message = Cliaws.sqs.receive(queue_name)
        puts message if message
      end

      desc "pop QUEUE_NAME", "Prints a message from the queue to STDOUT, and removes it from the queue."
      def pop(queue_name)
        message = Cliaws.sqs.pop(queue_name)
        puts message if message
      end

      desc "push QUEUE_NAME [LOCAL_FILE]", <<EOD
Pushes a new message to the named queue.

Reads STDIN if LOCAL_FILE and --data are absent.
EOD
      method_options :data => :string
      def push(queue_name, local_file=nil)
        raise ArgumentError, "Cannot give both --data and LOCAL_FILE" if options[:data] && local_file
        data = case
               when local_file
                 File.read(local_file)
               when options[:data]
                 options[:data]
               else
                 STDIN.read
               end
        Cliaws.sqs.push(queue_name, data)
        puts "Pushed #{data.size} bytes to queue #{queue_name}"
      end

      desc "info QUEUE_NAME", "Returns information about the named queue, as a YAML document."
      def info(queue_name)
        info = Cliaws.sqs.info(queue_name)
        data = {"Visibility" => info[:visibility_timeout], "Number of messages" => info[:size]}
        puts data.to_yaml
      end
    end
  end
end
