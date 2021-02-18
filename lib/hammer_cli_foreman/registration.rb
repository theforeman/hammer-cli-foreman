module HammerCLIForeman
  class Registration < HammerCLIForeman::Command
    resource :registration_commands

    class GenerateCommand < HammerCLIForeman::CreateCommand
      command_name 'generate-command'
      failure_message _("Failed to generate registration command")

      def print_data(registration_command)
        puts registration_command
      end

      build_options
    end

    autoload_subcommands
  end
end
