require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/resource_supported_test'

module HammerCLIForeman

  class Location < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand
      include HammerCLIForeman::ResourceSupportedTest
      resource ForemanApi::Resources::Location, "index"

      heading "Locations"
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
      resource ForemanApi::Resources::Location, "show"

      heading "Location info"
      output ListCommand.output_definition do
        from "location" do
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Location created"
      failure_message "Could not create the location"
      resource ForemanApi::Resources::Location, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Location updated"
      failure_message "Could not update the location"
      resource ForemanApi::Resources::Location, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message "Location deleted"
      failure_message "Could not delete the location"
      resource ForemanApi::Resources::Location, "destroy"

      apipie_options
    end

    subcommand "list", "List locations.", HammerCLIForeman::Location::ListCommand
    subcommand "info", "Detailed info about an location.", HammerCLIForeman::Location::InfoCommand
    subcommand "create", "Create new location.", HammerCLIForeman::Location::CreateCommand
    subcommand "update", "Update an location.", HammerCLIForeman::Location::UpdateCommand
    subcommand "delete", "Delete an location.", HammerCLIForeman::Location::DeleteCommand
  end

end

HammerCLI::MainCommand.subcommand 'location', "Manipulate Foreman's locations.", HammerCLIForeman::Location

