Gem::Specification.new do |s|
  s.name = %q{cliaws}
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fran\303\247ois Beausoleil"]
  s.date = %q{2008-10-26}
  s.description = %q{A command-line suite of tools to access Amazon Web Services, using the RightAws gems.}
  s.email = ["francois@teksol.info"]
  s.executables = ["clis3", "clisqs", "cliec2"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "vendor/right_http_connection-1.2.1/README.txt"]
  s.files = [".gitignore", "History.txt", "License.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/cliec2", "bin/clis3", "bin/clisqs", "config/hoe.rb", "config/requirements.rb", "lib/cliaws.rb", "lib/cliaws/ec2.rb", "lib/cliaws/s3.rb", "lib/cliaws/sqs.rb", "lib/cliaws/version.rb", "log/.gitignore", "script/console", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "tasks/deployment.rake", "tasks/environment.rake", "test/test_cliaws.rb", "test/test_helper.rb", "vendor/right_http_connection-1.2.1/README.txt", "vendor/right_http_connection-1.2.1/lib/right_http_connection.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://cliaws.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cliaws}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A command-line suite of tools to access Amazon Web Services, using the RightAws gems.}
  s.test_files = ["test/test_cliaws.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<main>, ["~> 2.8"])
      s.add_runtime_dependency(%q<right_aws>, ["~> 1.8"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<main>, ["~> 2.8"])
      s.add_dependency(%q<right_aws>, ["~> 1.8"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<main>, ["~> 2.8"])
    s.add_dependency(%q<right_aws>, ["~> 1.8"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
