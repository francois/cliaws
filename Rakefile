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
    gemspec.executables       = %w(clis3 clisqs cliec2)
    gemspec.extra_rdoc_files  = %w(History.txt License.txt vendor/right_http_connection-1.2.1/README.txt)

    gemspec.add_dependency "thor", "~> 0.9"
    gemspec.add_dependency "right_aws", "~> 1.10"
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
        remote_dir = "/var/www/gforge-projects/cliaws/"
        local_dir = 'doc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end

task :rdoc do
  rm_r "doc"
  sh "rdoc --title 'Cliaws: Ruby command-line AWS client' --exclude=doc/"
end
