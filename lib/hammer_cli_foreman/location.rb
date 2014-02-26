require 'hammer_cli_foreman/resource_supported_test'

module HammerCLIForeman

  class Location < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Location

    class ListCommand < HammerCLIForeman::ListCommand
      include HammerCLIForeman::ResourceSupportedTest

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      include HammerCLIForeman::ResourceSupportedTest

      output ListCommand.output_definition do
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message _("Location created")
      failure_message _("Could not create the location")

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message _("Location updated")
      failure_message _("Could not update the location")

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message _("Location deleted")
      failure_message _("Could not delete the location")

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

HammerCLI::MainCommand.subcommand 'location', _("Manipulate locations."), HammerCLIForeman::Location

