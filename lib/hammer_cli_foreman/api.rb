require 'hammer_cli_foreman/api/connection'

module HammerCLIForeman
  module Api
    class UnauthorizedError < RuntimeError; end
  end
end

HammerCLIForeman.init_api_connection
