# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "hammer_cli_foreman/version"

Gem::Specification.new do |s|

  s.name          = "hammer_cli_foreman"
  s.version       = HammerCLIForeman.version.dup
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Tomáš Strachota", "Martin Bačovský"]
  s.email         = "tstracho@redhat.com"
  s.homepage      = "https://github.com/theforeman/hammer-cli-foreman"
  s.license       = "GPL-3.0+"

  s.summary       = %q{Foreman commands for Hammer}
  s.description   = <<EOF
Foreman commands for Hammer CLI
EOF

  locales = Dir['locale/*'].select { |f| File.directory?(f) }
  s.files = Dir['{lib,doc,test,config}/**/*', 'LICENSE', 'README*'] +
    locales.map { |loc| "#{loc}/LC_MESSAGES/hammer-cli-foreman.mo" }

  s.test_files       = Dir['{test}/**/*']
  s.extra_rdoc_files = Dir['{doc}/**/*', 'README*']
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli', '>= 0.18.0'
  s.add_dependency 'apipie-bindings', '>= 0.3.0'
  s.add_dependency 'rest-client', '>= 1.8.0', '< 3.0.0'
  s.add_dependency 'jwt', '>= 2.2.1'

end
