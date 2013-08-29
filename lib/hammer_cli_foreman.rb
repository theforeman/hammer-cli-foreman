require 'hammer_cli'
require 'hammer_cli/exit_codes'

module HammerCLIForeman

  def self.exception_handler_class
    HammerCLIForeman::ExceptionHandler
  end

  require 'hammer_cli_foreman/exception_handler'
  require 'hammer_cli_foreman/architecture'
  require 'hammer_cli_foreman/common_parameter'
  require 'hammer_cli_foreman/compute_resource'
  require 'hammer_cli_foreman/domain'
  require 'hammer_cli_foreman/environment'
  require 'hammer_cli_foreman/host'
  require 'hammer_cli_foreman/hostgroup'
  require 'hammer_cli_foreman/location'
  require 'hammer_cli_foreman/media'
  require 'hammer_cli_foreman/operating_system'
  require 'hammer_cli_foreman/organization'
  require 'hammer_cli_foreman/partition_table'
  require 'hammer_cli_foreman/smart_proxy'
  require 'hammer_cli_foreman/subnet'
  require 'hammer_cli_foreman/template'
  require 'hammer_cli_foreman/user'

end

