require "right_aws"
require "activesupport"

module Cliaws
  class Sqs
    def initialize(access_key_id, secret_access_key)
      @sqs = RightAws::Sqs.new(access_key_id, secret_access_key, :logger => Logger.new("/dev/null"))
    end

    # Gets a message from the queue, but doesn't delete it.
    def receive(qname)
      q(qname).receive(qname).to_s
    end

    # Adds a message in the queue.
    def send(qname, data)
      q(qname).push(data)
    end

    # Gets and deletes message.
    def pop(qname)
      q(qname).pop.to_s
    end

    # Returns the size of the queue.
    def size(qname)
      q(qname).size
    end

    # Lists the created queues.
    def list(prefix=nil)
      @sqs.queues(prefix).map(&:name)
    end

    # Creates a queue
    def create(qname)
      q(qname, true)
    end

    # Deletes a queue.  +force+ must be true to delete a queue with pending messages.
    def delete(qname, force=false)
      q(qname).delete(force)
    end

    protected
    def q(qname, create=false)
      @sqs.queue(qname, create)
    end
  end
end