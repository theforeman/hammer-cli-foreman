require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/associating_commands'

module HammerCLIForeman

  class Architecture < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Architecture

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, "Id"
        field :name, "Name"
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :operatingsystem_ids, "OS ids", Fields::List
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message "Architecture created"
      failure_message "Could not create the architecture"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message "Architecture deleted"
      failure_message "Could not delete the architecture"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message "Architecture updated"
      failure_message "Could not update the architecture"

      apipie_options
    end

    include HammerCLIForeman::AssociatingCommands::OperatingSystem

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'architecture', "Manipulate architectures.", HammerCLIForeman::Architecture

