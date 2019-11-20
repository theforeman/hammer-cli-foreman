module HammerCLIForeman
  module Authenticate
    module Login
      def execute_with_params(auth_type, *args)
        connection = HammerCLIForeman.foreman_api_reconnect(auth_type)
        if !(connection.authenticator.is_a?(HammerCLIForeman::Api::SessionAuthenticatorWrapper))
          raise ArgumentError, _("Can't perform login. Make sure sessions are enabled in hammer"\
            " configuration file.")
        end
        connection.authenticator.set_auth_params(*args)
        connection.authenticator.force_user_change
        connection.login
      end
    end
  end
end
