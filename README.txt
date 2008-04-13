= cliaws

* http://rubyforge.org/projects/cliaws

== DESCRIPTION:

A command-line client for Amazon Web Services.

== FEATURES/PROBLEMS:

* Amazon keys are read from the environment only.  They environment keys must
  be named:  AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
* Minimal amount of error checking is done.  Check the command's status after
  each call.
* No logging.

== SYNOPSIS:

Usage from the command line:

  $ clis3 list my_awesome_bucket/a_glob
  $ clis3 put my_awesome_bucket/a_key_name a_local_file
  $ cat a_local_file | clis3 put my_awesome_bucket/a_key_name
  $ clis3 put --data "this is the data" my_awesome_bucket/a_key_name
  $ clis3 get my_awesome_bucket/a_key_name a_local_file
  $ clis3 get my_awesome_bucket/a_key_name # Outputs to STDOUT
  $ clis3 cat my_awesome_bucket/a_key_name # Outputs to STDOUT, but adds an extra newline
  $ clis3 head my_awesome_bucket/a_key_name
    # Returns a YAML representation of response and metadata headers
  $ clis3 rm my_awesome_bucket/a_key_name

Cliaws may also be used from Ruby:

  Cliaws.s3.list("my_awesome_bucket/a_glob") # Returns an array of names
  Cliaws.s3.put(File.open("a_local_file", "rb"), "my_awesome_bucket/a_key_name")
  Cliaws.s3.put(STDIN, "my_awesome_bucket/a_key_name")
  Cliaws.s3.put("this is the data", "my_awesome_bucket/a_key_name")
  Cliaws.s3.get("my_awesome_bucket/a_key_name")
  Cliaws.s3.head("my_awesome_bucket/a_key_name")
  Cliaws.s3.rm("my_awesome_bucket/a_key_name")

== REQUIREMENTS:

* main
* activesupport
* right_aws

== INSTALL:

* sudo gem install cliaws

== LICENSE:

(The MIT License)

Copyright (c) 2008 François Beausoleil (francois@teksol.info)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
