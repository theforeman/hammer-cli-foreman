require 'hammer_cli_foreman/api/basic_auth'

module HammerCLIForeman
  module Api
    class InteractiveBasicAuthExternal < ApipieBindings::Authenticators::BasicAuthExternal
      include HammerCLIForeman::Api::BasicAuth

      def initialize(user, password, foreman_url)
        super(user, password, "#{foreman_url}/api/users/extlogin", HammerCLI::SSLOptions.new.get_options(foreman_url))
      end

      def session_id
        auth_cookie&.delete_prefix('_session_id=')
      end
    end
  end
end
