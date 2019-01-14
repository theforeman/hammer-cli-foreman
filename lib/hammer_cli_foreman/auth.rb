require 'hammer_cli_foreman/openid_connect.rb'
require 'hammer_cli_foreman/authenticate/login.rb'

module HammerCLIForeman
  class Auth < HammerCLI::AbstractCommand
    class LoginCommand < HammerCLI::AbstractCommand
      command_name 'login'
      desc _("Set credentials")

      class Basic < HammerCLI::AbstractCommand
        extend HammerCLIForeman::Authenticate::Login

        command_name('basic')
        desc('provide username and password')

        option ["-u", "--username"], "USERNAME", _("Username to access the remote system")
        option ["-p", "--password"], "PASSWORD", _("Password to access the remote system")

        def execute
          Basic.execute_with_params(
            AUTH_TYPES[:basic_auth],
            option_username || HammerCLI::Settings.get('_params', 'username'),
            option_password || HammerCLI::Settings.get('_params', 'password')
          )
        end
      end

      class Oauth < HammerCLI::AbstractCommand
        extend HammerCLIForeman::Authenticate::Login

        command_name('oauth')
        desc('supports for both with/without 2fa')

        option ["-u", "--username"], "USERNAME", _("Username to access the remote system")
        option ["-p", "--password"], "PASSWORD", _("Password to access the remote system")
        option ["-t", "--oidc-token-endpoint"], "OPENIDC-TOKEN-ENDPOINT", _("Openidc provider URL which issues access token")
        option ["-a", "--oidc-authorization-endpoint"], "OPENIDC-AUTHORIZATION-ENDPOINT", _("Openidc provider URL which issues authentication code")
        option ["-c", "--oidc-client-id"], "OPENIDC-CLIENT-ID", _("Client id used in the Openidc provider")
        option ["-f", "--two-factor"], :flag, _("Authenticate with two factor")
        option ["-r", "--oidc-redirect-uri"], "OPENIDC-REDIRECT-URI", _("Redirect URI for the authencation code grant flow")

        def execute
          if option_two_factor?
            Oauth.execute_with_params(
              AUTH_TYPES[:oauth_authentication_code_grant],
              option_oidc_token_endpoint,
              option_oidc_authorization_endpoint,
              option_oidc_client_id,
              option_oidc_redirect_uri
            )
          else
            Oauth.execute_with_params(
              AUTH_TYPES[:oauth_password_grant],
              option_oidc_token_endpoint,
              option_oidc_client_id,
              option_username || HammerCLI::Settings.get('_params', 'username'),
              option_password || HammerCLI::Settings.get('_params', 'password')
            )
          end
        end
        autoload_subcommands
      end

      autoload_subcommands
    end

    class LogoutCommand < HammerCLI::AbstractCommand
      command_name "logout"
      desc _("Wipe your credentials")

      def execute
        HammerCLIForeman.foreman_api_connection.logout
        print_message(_("Logged out."))
        HammerCLI::EX_OK
      end
    end

    class InfoCommand < HammerCLI::AbstractCommand
      command_name "status"
      desc _("Information about current connections")

      def execute
        print_message(HammerCLIForeman.foreman_api_connection.login_status)
        HammerCLI::EX_OK
      end
    end

    autoload_subcommands
  end
end
