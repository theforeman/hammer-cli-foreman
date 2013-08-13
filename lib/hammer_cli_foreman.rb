require 'hammer_cli'
require 'hammer_cli_foreman/exception_handler'


module HammerCLIForeman

  def self.exception_handler_class
    HammerCLIForeman::ExceptionHandler
  end

  require 'hammer_cli_foreman/architecture'
  require 'hammer_cli_foreman/compute_resource'
  require 'hammer_cli_foreman/domain'
  require 'hammer_cli_foreman/environment'
  require 'hammer_cli_foreman/location'
  require 'hammer_cli_foreman/organization'
  require 'hammer_cli_foreman/subnet'
  require 'hammer_cli_foreman/user'

end

