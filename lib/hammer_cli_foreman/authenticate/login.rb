module HammerCLIForeman
  module Authenticate
    module Login
      def execute_with_params(auth_type, *args)
        connection = HammerCLIForeman.foreman_api_reconnect(auth_type)
        if !(connection.authenticator.is_a?(HammerCLIForeman::Api::SessionAuthenticatorWrapper))
          HammerCLI.interactive_output.say(_("Can't perform login. Make sure sessions are enabled in hammer"\
            " configuration file."))
          return HammerCLI::EX_USAGE
        end
        connection.authenticator.set_auth_params(*args)
        connection.authenticator.force_user_change
        connection.login

        HammerCLI.interactive_output.say(_("Successfully logged in as '%s'.") %
          connection.authenticator.user)
        HammerCLI::EX_OK
      end
    end
  end
end
