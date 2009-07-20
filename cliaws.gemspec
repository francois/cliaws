# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cliaws}
  s.version = "1.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fran\303\247ois Beausoleil"]
  s.date = %q{2009-07-20}
  s.description = %q{A command-line suite of tools to access Amazon Web Services, using the RightAws gems.}
  s.email = %q{francois@teksol.info}
  s.executables = ["clis3", "clisqs", "cliec2"]
  s.extra_rdoc_files = [
    "History.txt",
     "License.txt"
  ]
  s.files = [
    ".gitignore",
     "History.txt",
     "License.txt",
     "README.txt",
     "Rakefile",
     "VERSION",
     "bin/cliec2",
     "bin/clis3",
     "bin/clisdb",
     "bin/clisqs",
     "cliaws.gemspec",
     "lib/cliaws.rb",
     "lib/cliaws/cli/ec2.rb",
     "lib/cliaws/cli/s3.rb",
     "lib/cliaws/cli/sqs.rb",
     "lib/cliaws/ec2.rb",
     "lib/cliaws/s3.rb",
     "lib/cliaws/sqs.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://cliaws.rubyforge.org/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cliaws}
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{A command-line suite of tools to access Amazon Web Services, using the RightAws gems.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, ["~> 0.9"])
      s.add_runtime_dependency(%q<right_aws>, ["~> 1.10"])
    else
      s.add_dependency(%q<thor>, ["~> 0.9"])
      s.add_dependency(%q<right_aws>, ["~> 1.10"])
    end
  else
    s.add_dependency(%q<thor>, ["~> 0.9"])
    s.add_dependency(%q<right_aws>, ["~> 1.10"])
  end
end
