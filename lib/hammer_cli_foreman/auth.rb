module HammerCLIForeman

  class Auth < HammerCLI::AbstractCommand

    class LoginCommand < HammerCLI::AbstractCommand
      command_name "login"
      desc "Set credentials"

      def execute
        HammerCLIForeman.credentials.clear
        HammerCLI::Connection.drop_all
        HammerCLIForeman.credentials.username
        HammerCLIForeman.credentials.password
        HammerCLI::EX_OK
      end
    end

    class LogoutCommand < HammerCLI::AbstractCommand
      command_name "logout"
      desc "Wipe your credentials"

      def execute
        #NOTE: we will change that to drop(:foreman) once dynamic bindings are implemented
        HammerCLIForeman.credentials.clear
        HammerCLI::Connection.drop_all
        print_message("Credentials deleted.")
        HammerCLI::EX_OK
      end
    end

    class InfoCommand < HammerCLI::AbstractCommand
      command_name "status"
      desc "Information about current connections"

      def execute
        unless HammerCLIForeman.credentials.empty?
          print_message("You are logged in as '%s'" % HammerCLIForeman.credentials.username)
        else
          print_message("You are currently not logged in to any service.\nUse the service to set credentials.")
        end
        HammerCLI::EX_OK
      end
    end

    autoload_subcommands
  end

  HammerCLI::ShellMainCommand.subcommand 'auth', "Foreman connection login/logout.", HammerCLIForeman::Auth
end
