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
          logged_user = HammerCLIForeman.foreman_api_connection.authenticator.user
          print_message(_("Successfully logged in as '%s'.") % logged_user)
          HammerCLI::EX_OK
        end
      end

      class Negotiate < HammerCLI::AbstractCommand
        extend HammerCLIForeman::Authenticate::Login

        command_name('negotiate')
        desc('negotiate the login credentials from the auth ticket (Kerberos)')

        def execute
          Negotiate.execute_with_params(AUTH_TYPES[:negotiate])
          print_message(_("Successfully authenticated using negotiate auth, using the KEYRING principal."))
          HammerCLI::EX_OK
        end
      end

      class Oauth < HammerCLI::AbstractCommand
        extend HammerCLIForeman::Authenticate::Login

        command_name('oauth')
        desc('supports for both with/without 2fa')

        option ["-u", "--username"], "USERNAME", _("Username to access the remote system")
        option ["-p", "--password"], "PASSWORD", _("Password to access the remote system")
        option ["-t", "--oidc-token-endpoint"], "OPENIDC_TOKEN_ENDPOINT", _("Openidc provider URL which issues access token")
        option ["-a", "--oidc-authorization-endpoint"], "OPENIDC_AUTHORIZATION_ENDPOINT", _("Openidc provider URL which issues authentication code (two factor only)")
        option ["-c", "--oidc-client-id"], "OPENIDC_CLIENT_ID", _("Client id used in the Openidc provider")
        option ["-f", "--two-factor"], :flag, _("Authenticate with two factor")
        option ["-r", "--oidc-redirect-uri"], "OPENIDC_REDIRECT_URI", _("Redirect URI for the authentication code grant flow")

        def execute
          if option_two_factor?
            Oauth.execute_with_params(
              AUTH_TYPES[:oauth_authentication_code_grant],
              option_oidc_token_endpoint || HammerCLI::Settings.get(:foreman, :oidc_token_endpoint),
              option_oidc_authorization_endpoint || HammerCLI::Settings.get(:foreman, :oidc_authorization_endpoint),
              option_oidc_client_id || HammerCLI::Settings.get(:foreman, :oidc_client_id),
              option_oidc_redirect_uri || HammerCLI::Settings.get(:foreman, :oidc_redirect_uri)
            )
          else
            Oauth.execute_with_params(
              AUTH_TYPES[:oauth_password_grant],
              option_oidc_token_endpoint || HammerCLI::Settings.get(:foreman, :oidc_token_endpoint),
              option_oidc_client_id || HammerCLI::Settings.get(:foreman, :oidc_client_id),
              option_username || HammerCLI::Settings.get('_params', 'username'),
              option_password || HammerCLI::Settings.get('_params', 'password')
            )
          end
          logged_user = HammerCLIForeman.foreman_api_connection.authenticator.user
          print_message(_("Successfully logged in as '%s'.") % logged_user)
          HammerCLI::EX_OK
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
