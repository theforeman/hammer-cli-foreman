require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'

module HammerCLIForeman

  class Environment < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::Environment, "index"

      heading "Environments"
      output do
        from "environment" do
          field :id, "Id"
          field :name, "Name"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      resource ForemanApi::Resources::Environment, "show"

      heading "Environment info"
      output ListCommand.output_definition do
        from "environment" do
          field :created_at, "Created at", &HammerCLIForeman::Formatters.method(:date_formatter)
          field :updated_at, "Updated at", &HammerCLIForeman::Formatters.method(:date_formatter)
        end
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Environment created"
      failure_message "Could not create the environment"
      resource ForemanApi::Resources::Environment, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Environment updated"
      failure_message "Could not update the environment"
      resource ForemanApi::Resources::Environment, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Environment deleted"
      failure_message "Could not delete the environment"
      resource ForemanApi::Resources::Environment, "destroy"

      apipie_options
    end

    subcommand "list", "List environments.", HammerCLIForeman::Environment::ListCommand
    subcommand "info", "Detailed info about an environment.", HammerCLIForeman::Environment::InfoCommand
    subcommand "create", "Create new environment.", HammerCLIForeman::Environment::CreateCommand
    subcommand "update", "Update an environment.", HammerCLIForeman::Environment::UpdateCommand
    subcommand "delete", "Delete an environment.", HammerCLIForeman::Environment::DeleteCommand
  end

end

HammerCLI::MainCommand.subcommand 'environment', "Manipulate Foreman's environments.", HammerCLIForeman::Environment

