require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class Architecture < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand

      heading "Architecture list"
      output do
        from "architecture" do
          field :id, "Id"
          field :name, "Name"
        end
      end

      resource ForemanApi::Resources::Architecture, "index"
      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      heading "Architecture info"
      output ListCommand.output_definition do
        from "architecture" do
          field :operatingsystem_ids, "OS ids"
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
      end

      resource ForemanApi::Resources::Architecture, "show"

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Architecture created"
      failure_message "Could not create the architecture"
      resource ForemanApi::Resources::Architecture, "create"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Architecture deleted"
      failure_message "Could not delete the architecture"
      resource ForemanApi::Resources::Architecture, "destroy"

    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Architecture updated"
      failure_message "Could not update the architecture"
      resource ForemanApi::Resources::Architecture, "update"

      apipie_options
    end

    subcommand "list", "List architectures.", HammerCLIForeman::Architecture::ListCommand
    subcommand "info", "Detailed info about an architecture.", HammerCLIForeman::Architecture::InfoCommand
    subcommand "create", "Create new architecture.", HammerCLIForeman::Architecture::CreateCommand
    subcommand "update", "Update an architecture.", HammerCLIForeman::Architecture::UpdateCommand
    subcommand "delete", "Delete an architecture.", HammerCLIForeman::Architecture::DeleteCommand
  end

end

HammerCLI::MainCommand.subcommand 'architecture', "Manipulate Foreman's architectures.", HammerCLIForeman::Architecture

