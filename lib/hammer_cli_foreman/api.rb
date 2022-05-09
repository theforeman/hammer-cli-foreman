require 'hammer_cli_foreman/api/connection'

module HammerCLIForeman
  module Api
    class UnauthorizedError < RuntimeError; end
    class SessionExpired < UnauthorizedError; end
  end
end

api = HammerCLIForeman.init_api_connection.api
api.update_cache(api.check_cache)
