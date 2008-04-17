$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "cliaws/s3"
require "cliaws/sqs"

module Cliaws
  def self.access_key_id
    ENV["AWS_ACCESS_KEY_ID"]
  end

  def self.secret_access_key
    ENV["AWS_SECRET_ACCESS_KEY"]
  end

  def self.s3
    @@s3 ||= Cliaws::S3.new(access_key_id, secret_access_key)
  end

  def self.sqs
    @@sqs ||= Cliaws::Sqs.new(access_key_id, secret_access_key)
  end
end
