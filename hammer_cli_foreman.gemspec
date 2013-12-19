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
  s.license       = "GPL v3+"

  s.summary       = %q{Foreman commands for Hammer}
  s.description   = <<EOF
Foreman commands for Hammer CLI
EOF



  s.files            = Dir['{lib,doc,test}/**/*', 'README*']
  s.test_files       = Dir['{test}/**/*']
  s.extra_rdoc_files = Dir['{doc}/**/*', 'README*']
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli', '>= 0.0.12'
  s.add_dependency 'foreman_api', '= 0.1.8'

  # required for ruby < 1.9.0:
  s.add_dependency 'mime-types', '< 2.0.0' #newer versions of mime-types are not 1.8 compatible

end
