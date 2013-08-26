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

  # s.files         = `git ls-files`.split("\n")
  s.files = Dir['lib/**/*.rb'] + Dir['bin/*']
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.test_files = Dir.glob('test/tc_*.rb')
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli'
  s.add_dependency 'foreman_api', '>= 0.1.6'
  s.add_dependency 'awesome_print'
  s.add_dependency 'terminal-table'

end
