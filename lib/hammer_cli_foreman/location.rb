require 'hammer_cli_foreman/resource_supported_test'

module HammerCLIForeman

  class Location < HammerCLIForeman::Command

    resource :locations

    class ListCommand < HammerCLIForeman::ListCommand
      include HammerCLIForeman::ResourceSupportedTest

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :description, _("Description")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      include HammerCLIForeman::ResourceSupportedTest

      option '--id', 'ID', _("Location numeric id to search by")

      output ListCommand.output_definition do
        field nil, _("Parent"), Fields::SingleReference, :key => :parent
        HammerCLIForeman::References.users(self)
        HammerCLIForeman::References.smart_proxies(self)
        HammerCLIForeman::References.subnets(self)
        HammerCLIForeman::References.compute_resources(self)
        HammerCLIForeman::References.media(self)
        HammerCLIForeman::References.config_templates(self)
        HammerCLIForeman::References.domains(self)
        HammerCLIForeman::References.environments(self)
        HammerCLIForeman::References.hostgroups(self)
        HammerCLIForeman::References.parameters(self)
        collection :organizations, _("Organizations"), :numbered => false, :hide_blank => true do
          custom_field Fields::Reference
        end
        HammerCLIForeman::References.timestamps(self)
      end

      build_options do |o|
        o.expand.primary(:organizations)
      end
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

      build_options do |o|
        o.expand.primary(:organizations)
      end
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for a location.")

      success_message_for :update, _("Parameter [%{name}] updated to value [%{value}]")
      success_message_for :create, _("Parameter [%{name}] created with value [%{value}]")
      failure_message _("Could not set location parameter")

      build_options
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for a location.")

      success_message _("Parameter [%{name}] deleted")
      failure_message _("Could not delete location parameter")

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



