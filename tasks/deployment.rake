desc 'Release the website and new gem version'
task :deploy => [:check_version, :website, :release] do
  puts "Remember to create SVN tag:"
  puts "svn copy svn+ssh://#{rubyforge_username}@rubyforge.org/var/svn/#{PATH}/trunk " +
  "svn+ssh://#{rubyforge_username}@rubyforge.org/var/svn/#{PATH}/tags/REL-#{VERS} "
  puts "Suggested comment:"
  puts "Tagging release #{CHANGES}"
end

desc 'Runs tasks website_generate and install_gem as a local deployment of the gem'
task :local_deploy => [:website_generate, :install_gem]

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == VERS
    puts "Please update your version.rb to match the release version, currently #{VERS}"
    exit
  end
end

desc 'Install the package as a gem, without generating documentation(ri/rdoc)'
task :install_gem_no_doc => [:clean, :package] do
  sh "#{'sudo ' unless Hoe::WINDOZE }gem install pkg/*.gem --no-rdoc --no-ri"
end

namespace :manifest do
  desc 'Recreate Manifest.txt to include ALL files'
  task :refresh do
    require "find"

    home = File.expand_path(File.dirname(__FILE__) + "/../") + "/"
    files = []
    Find.find(File.dirname(__FILE__) + "/..") do |entry|
      Find.prune if entry =~ /\.git$/
      next if File.directory?(entry)
      files << File.expand_path(entry).sub(home, "")
    end

    File.open(File.dirname(__FILE__) + "/../Manifest.txt", "w") do |io|
      io.puts files.sort.join("\n")
    end
  end
end
