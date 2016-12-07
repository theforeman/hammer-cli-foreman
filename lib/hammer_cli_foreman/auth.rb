module HammerCLIForeman

  class Auth < HammerCLI::AbstractCommand

    class LoginCommand < HammerCLI::AbstractCommand
      command_name "login"
      desc _("Set credentials")

      def execute
        HammerCLIForeman.foreman_api_connection.logout
        context[:api_connection].drop_all
        HammerCLIForeman.foreman_api_connection.login
        HammerCLI::EX_OK
      end
    end

    class LogoutCommand < HammerCLI::AbstractCommand
      command_name "logout"
      desc _("Wipe your credentials")

      def execute
        HammerCLIForeman.foreman_api_connection.logout
        context[:api_connection].drop_all
        print_message(_("Credentials deleted."))
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
