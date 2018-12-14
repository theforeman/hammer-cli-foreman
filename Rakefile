require 'rake/testtask'
require 'bundler/gem_tasks'
require 'ci/reporter/rake/minitest'
require 'hammer_cli/i18n/find_task'
require_relative './lib/hammer_cli_foreman/version'
require_relative './lib/hammer_cli_foreman/i18n'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.verbose = true
end

HammerCLI::I18n::FindTask.define(HammerCLIForeman::I18n::LocaleDomain.new, HammerCLIForeman.version)

namespace :pkg do
  desc 'Generate package source gem'
  task :generate_source => :build
end
