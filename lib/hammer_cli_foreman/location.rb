require 'hammer_cli_foreman/resource_supported_test'

module HammerCLIForeman

  class Location < HammerCLIForeman::Command

    resource :locations

    class ListCommand < HammerCLIForeman::ListCommand
      include HammerCLIForeman::ResourceSupportedTest

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      include HammerCLIForeman::ResourceSupportedTest

      option '--id', 'ID', _("Location numeric id to search by")

      include HammerCLIForeman::References::Users
      include HammerCLIForeman::References::SmartProxies
      include HammerCLIForeman::References::Subnets
      include HammerCLIForeman::References::ComputeResources
      include HammerCLIForeman::References::Media
      include HammerCLIForeman::References::ConfigTemplates
      include HammerCLIForeman::References::Domains
      include HammerCLIForeman::References::Environments
      include HammerCLIForeman::References::Hostgroups
      include HammerCLIForeman::References::Parameters
      output ListCommand.output_definition do
        collection :organizations, _("Organizations"), :numbered => false, :hide_blank => true do
          custom_field Fields::Reference
        end
      end
      include HammerCLIForeman::References::Timestamps

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include HammerCLIForeman::ResourceSupportedTest

      success_message _("Location created")
      failure_message _("Could not create the location")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include HammerCLIForeman::ResourceSupportedTest

      option '--id', 'ID', _("Location numeric id to search by")

      success_message _("Location updated")
      failure_message _("Could not update the location")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      include HammerCLIForeman::ResourceSupportedTest

      option '--id', 'ID', _("Location numeric id to search by")

      success_message _("Location deleted")
      failure_message _("Could not delete the location")

      build_options
    end

    HammerCLIForeman::AssociatingCommands::Hostgroup.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Environment.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Domain.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Medium.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Subnet.extend_command(self)
    HammerCLIForeman::AssociatingCommands::ComputeResource.extend_command(self)
    HammerCLIForeman::AssociatingCommands::SmartProxy.extend_command(self)
    HammerCLIForeman::AssociatingCommands::User.extend_command(self)
    HammerCLIForeman::AssociatingCommands::ConfigTemplate.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Organization.extend_command(self)

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'location', _("Manipulate locations."), HammerCLIForeman::Location

