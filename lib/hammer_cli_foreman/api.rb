require 'hammer_cli_foreman/api/connection'

module HammerCLIForeman
  module Api
    class UnauthorizedError < RuntimeError; end
    class SessionExpired < UnauthorizedError; end
  end
end

HammerCLIForeman.init_api_connection
