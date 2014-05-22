require 'hammer_cli'
require 'hammer_cli/exit_codes'
require 'apipie_bindings'

module HammerCLIForeman

  def self.exception_handler_class
    HammerCLIForeman::ExceptionHandler
  end

  require 'hammer_cli_foreman/i18n'

  require 'hammer_cli_foreman/version'
  require 'hammer_cli_foreman/output'
  require 'hammer_cli_foreman/credentials'
  require 'hammer_cli_foreman/exception_handler'
  require 'hammer_cli_foreman/searchables_option_builder'
  require 'hammer_cli_foreman/id_resolver'

  begin
    require 'hammer_cli_foreman/commands'
    require 'hammer_cli_foreman/associating_commands'
    require 'hammer_cli_foreman/references'
    require 'hammer_cli_foreman/parameter'
    require 'hammer_cli_foreman/common_parameter'

    require 'hammer_cli_foreman/architecture'
    require 'hammer_cli_foreman/auth'
    require 'hammer_cli_foreman/compute_resource'
    require 'hammer_cli_foreman/domain'
    require 'hammer_cli_foreman/environment'
    require 'hammer_cli_foreman/fact'
    require 'hammer_cli_foreman/host'
    require 'hammer_cli_foreman/hostgroup'
    require 'hammer_cli_foreman/location'
    require 'hammer_cli_foreman/media'
    require 'hammer_cli_foreman/model'
    require 'hammer_cli_foreman/operating_system'
    require 'hammer_cli_foreman/organization'
    require 'hammer_cli_foreman/output/fields'
    require 'hammer_cli_foreman/partition_table'
    require 'hammer_cli_foreman/report'
    require 'hammer_cli_foreman/puppet_class'
    require 'hammer_cli_foreman/smart_proxy'
    require 'hammer_cli_foreman/smart_class_parameter'
    require 'hammer_cli_foreman/subnet'
    require 'hammer_cli_foreman/template'
    require 'hammer_cli_foreman/user'

  rescue => e
    handler = HammerCLIForeman::ExceptionHandler.new(:context => {}, :adapter => :base)
    handler.handle_exception(e)
    raise HammerCLI::ModuleLoadingError.new(e)
  end

end

