require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/associating_commands'
require 'hammer_cli_foreman/resource_supported_test'

module HammerCLIForeman

  class Location < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Location

    class ListCommand < HammerCLIForeman::ListCommand
      include HammerCLIForeman::ResourceSupportedTest

      output do
        from "location" do
          field :id, "Id"
          field :name, "Name"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      include HammerCLIForeman::ResourceSupportedTest

      output ListCommand.output_definition do
        from "location" do
          field :created_at, "Created at", Fields::Date
          field :updated_at, "Updated at", Fields::Date
        end
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Location created"
      failure_message "Could not create the location"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Location updated"
      failure_message "Could not update the location"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Location deleted"
      failure_message "Could not delete the location"

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
    include HammerCLIForeman::AssociatingCommands::Organization

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'location', "Manipulate Foreman's locations.", HammerCLIForeman::Location

