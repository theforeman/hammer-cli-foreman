require 'fileutils'

module HammerCLIForeman
  module TaskHelper
    class PluginDraft
      attr_reader :name, :path

      def initialize(name, path, options = {})
        @plain_name = name
        @name = "hammer_cli_foreman_#{name}"
        @path = File.expand_path(@name.tr('_', '-'), path)
        @capitalized_bits = name.split('_').map(&:capitalize)
        @plugin_namespace = "HammerCLIForeman#{@capitalized_bits.join}"
        @core_location = File.expand_path('../../', File.dirname(__FILE__))
        @options = options
      end

      def build
        FileUtils.mkpath("#{@path}/lib/#{@name}")
        FileUtils.mkpath("#{@path}/config")
        FileUtils.mkpath("#{@path}/test")
        FileUtils.mkpath("#{@path}/locale")
      end

      def fill(&block)
        FileUtils.cd(@path) do
          self.instance_exec(&block)
        end
      end

      private

      def cp_license
        FileUtils.cp(File.expand_path('LICENSE', @core_location), FileUtils.pwd)
      end

      def mk_config
        File.open("config/foreman_#{@plain_name}.yml", 'w') do |config|
          config.write <<-EOF
:foreman_#{@plain_name}:
  :enable_module: true
EOF
        end
      end

      def mk_readme
        File.open('README.md', 'w') do |readme|
          readme.write <<-EOF
# TODO
EOF
        end
      end

      def mk_gemfile
        File.open('Gemfile', 'w') do |gemfile|
          gemfile.write <<-EOF
source "https://rubygems.org"

gemspec
EOF
        end
      end

      def mk_gemspec
        File.open("#{@name}.gemspec", 'w') do |gemspec|
          gemspec.write <<-EOF
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require '#{@name}/version'

Gem::Specification.new do |spec|
  spec.name          = '#{@name}'
  spec.version       = #{@plugin_namespace}.version.dup
  spec.authors       = ['#{@options[:author]}']
  spec.email         = ['#{@options[:email]}']
  spec.homepage      = 'https://github.com/theforeman/#{@name.tr('_', '-')}'
  spec.license       = 'GPL-3.0'

  spec.platform      = Gem::Platform::RUBY
  spec.summary       = 'Foreman #{@capitalized_bits.join(' ')} plugin for Hammer CLI'

  # TODO: Don't forget to update required files accordingly!
  spec.files         = Dir['{lib,config}/**/*', 'LICENSE', 'README*']
  spec.require_paths = ['lib']
  spec.test_files    = Dir['{test}/**/*']

  spec.add_dependency 'hammer_cli_foreman', '>= 2.0.0', '< 3.0.0'
end
EOF
        end
      end

      def mk_version
        File.open("lib/#{@name}/version.rb", 'w') do |version|
          version.write <<-EOF
module #{@plugin_namespace}
  def self.version
    @version ||= Gem::Version.new '0.0.1'
  end
end
EOF
        end
      end

      def mk_root
        File.open("lib/#{@name}.rb", 'w') do |plugin|
          plugin.write <<-EOF
module #{@plugin_namespace}
  require 'hammer_cli'
  require 'hammer_cli_foreman'

  require '#{@name}/version'
  require '#{@name}/resource'

  HammerCLI::MainCommand.lazy_subcommand(
    'resource',
    'Manage resources',
    '#{@plugin_namespace}::ResourceCommand',
    '#{@name}/resource'
  )
end
EOF
        end
      end

      def mk_boilerplate
        File.open("lib/#{@name}/resource.rb", 'w') do |resource_command|
          resource_command.write <<-EOF
module #{@plugin_namespace}
  class ResourceCommand < HammerCLIForeman::Command
    resource :resources

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ResourceCommand::ListCommand.output_definition do
        field :head_type, _('Head type')
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _('Resource created.')
      failure_message _('Could not create the resource')

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _('Resource updated.')
      failure_message _('Could not update the resource')

      build_options without: [:sprig]
      option '--head', 'HEAD', _('Head type'), attribute_name: :option_head
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _('Resource deleted.')
      failure_message _('Could not delete the resource')

      build_options
    end

    autoload_subcommands
  end
end
EOF
        end
      end
    end
  end
end
