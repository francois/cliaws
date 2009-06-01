begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name              = "cliaws"
    gemspec.rubyforge_project = gemspec.name
    gemspec.email             = "francois@teksol.info"
    gemspec.homepage          = "http://cliaws.rubyforge.org/"
    gemspec.summary           = "A command-line suite of tools to access Amazon Web Services, using the RightAws gems."
    gemspec.description       = gemspec.summary
    gemspec.authors           = ["François Beausoleil"]

    gemspec.add_dependency "main", "~> 2.8"
    gemspec.add_dependency "right_aws", "~> 1.8"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do

    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]

    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/the-perfect-gem/"
        local_dir = 'rdoc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end
