require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/associating_commands'
require 'hammer_cli_foreman/resource_supported_test'

module HammerCLIForeman

  class Organization < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Organization

    class ListCommand < HammerCLIForeman::ListCommand
      include HammerCLIForeman::ResourceSupportedTest

      heading "Organizations"
      output do
        from "organization" do
          field :id, "Id"
          field :name, "Name"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      include HammerCLIForeman::ResourceSupportedTest

      heading "Organization info"
      output ListCommand.output_definition do
        from "organization" do
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Organization created"
      failure_message "Could not create the organization"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Organization updated"
      failure_message "Could not update the organization"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Organization deleted"
      failure_message "Could not delete the organization"

      apipie_options
    end

    include HammerCLIForeman::AssociatingCommands::Hostgroup
    include HammerCLIForeman::AssociatingCommands::Environment
    include HammerCLIForeman::AssociatingCommands::Domain
    include HammerCLIForeman::AssociatingCommands::Medium
    include HammerCLIForeman::AssociatingCommands::Subnet
    include HammerCLIForeman::AssociatingCommands::ComputeResource
    include HammerCLIForeman::AssociatingCommands::SmartProxy
    include HammerCLIForeman::AssociatingCommands::User
    include HammerCLIForeman::AssociatingCommands::ConfigTemplate

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'organization', "Manipulate Foreman's organizations.", HammerCLIForeman::Organization

