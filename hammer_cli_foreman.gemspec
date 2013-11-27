# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "hammer_cli_foreman/version"

Gem::Specification.new do |s|

  s.name          = "hammer_cli_foreman"
  s.version       = HammerCLIForeman.version.dup
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Tomáš Strachota", "Martin Bačovský"]
  s.email         = "tstracho@redhat.com"
  s.homepage      = "http://github.com/theforeman/hammer-cli-foreman"

  s.summary       = %q{Foreman commands for Hammer}
  s.description   = <<EOF
Foreman commands for Hammer CLI
EOF



  s.files            = `git ls-files -- {lib,doc,test}/* README*`.split("\n")
  s.test_files       = `git ls-files -- test/*`.split("\n")
  s.extra_rdoc_files = `git ls-files -- doc/* README*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli', '>= 0.0.10'
  s.add_dependency 'foreman_api', '= 0.1.8'

  # required for ruby < 1.9.0:
  s.add_dependency 'mime-types', '< 2.0.0' if RUBY_VERSION < "1.9.0"

end
