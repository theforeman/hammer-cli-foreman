require 'rake/testtask'
require 'bundler/gem_tasks'
require 'ci/reporter/rake/minitest'
require 'hammer_cli/i18n/find_task'
require_relative './lib/hammer_cli_foreman/version'
require_relative './lib/hammer_cli_foreman/i18n'
require_relative './lib/hammer_cli_foreman/task_helper'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.verbose = true
  t.warning = ENV.key?('RUBY_WARNINGS')
end

HammerCLI::I18n::FindTask.define(HammerCLIForeman::I18n::LocaleDomain.new, HammerCLIForeman.version)

namespace :pkg do
  desc 'Generate package source gem'
  task :generate_source => :build
end

namespace :plugin do
  desc 'Create a plugin draft interactively'
  task :draft do |_t, args|
    require 'highline/import'
    require 'uri'

    options = {}
    options[:path] = ask('Directory to create the draft in: ') { |dir| dir.default = '../' }
    options[:name] = ask('Plugin name (e.g. my_plugin): ', String) do |name|
      name.validate = /\A[a-zA-Z]+([-_][a-zA-Z]+)*\Z/
      name.responses[:not_valid] = 'Valid names are: my_plugin, my-plugin, MyPlugin'
    end
    options[:author] = ask("Plugin's author (e.g. John Doe): ", String) do |author|
      author.validate = /\A[a-zA-Z]++(?: [a-zA-Z]++)*\Z/
      author.responses[:not_valid] = 'Valid names are: John, John Doe, John Doe S'
    end
    options[:email] = ask("Plugin's author e-mail (e.g. johndoe@example.com): ", String) do |email|
      email.validate = URI::MailTo::EMAIL_REGEXP
      email.responses[:not_valid] = 'Valid email is: johndoe@example.com'
    end
    options[:name] = options[:name].downcase.tr('-', '_')

    draft = HammerCLIForeman::TaskHelper::PluginDraft.new(
      options[:name], options[:path], author: options[:author], email: options[:email]
    )
    draft.build
    draft.fill do
      mk_config
      cp_license
      mk_readme
      mk_gemfile
      mk_gemspec
      mk_version
      mk_root
      mk_boilerplate
    end
    puts "Saved in #{draft.path}."
  end
end
