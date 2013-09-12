require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/associating_commands'

module HammerCLIForeman

  class Architecture < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Architecture

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        from "architecture" do
          field :id, "Id"
          field :name, "Name"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        from "architecture" do
          field :operatingsystem_ids, "OS ids", HammerCLI::Output::Fields::List
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message "Architecture created"
      failure_message "Could not create the architecture"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message "Architecture deleted"
      failure_message "Could not delete the architecture"
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

HammerCLI::MainCommand.subcommand 'architecture', "Manipulate Foreman's architectures.", HammerCLIForeman::Architecture

