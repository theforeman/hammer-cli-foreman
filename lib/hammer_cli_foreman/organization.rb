require 'hammer_cli_foreman/resource_supported_test'

module HammerCLIForeman

  class Organization < HammerCLIForeman::Command

    resource :organizations

    class ListCommand < HammerCLIForeman::ListCommand
      include HammerCLIForeman::ResourceSupportedTest

      output do
        field :id, _("Id")
        field :title, _("Title")
        field :name, _("Name")
        field :description, _("Description"), Fields::Text
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      include HammerCLIForeman::ResourceSupportedTest

      option "--id", "ID", " ", :referenced_resource => 'organization'

      output ListCommand.output_definition do
        field nil, _("Parent"), Fields::SingleReference, :key => :parent
        HammerCLIForeman::References.users(self)
        HammerCLIForeman::References.smart_proxies(self)
        HammerCLIForeman::References.subnets(self)
        HammerCLIForeman::References.compute_resources(self)
        HammerCLIForeman::References.media(self)
        HammerCLIForeman::References.provisioning_templates(self)
        HammerCLIForeman::References.partition_tables(self)
        HammerCLIForeman::References.domains(self)
        HammerCLIForeman::References.realms(self)
        HammerCLIForeman::References.environments(self)
        HammerCLIForeman::References.hostgroups(self)
        HammerCLIForeman::References.parameters(self)
        collection :locations, _("Locations"), :numbered => false, :hide_blank => true do
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

      success_message _("Organization created.")
      failure_message _("Could not create the organization")

      build_options

      extend_with(HammerCLIForeman::CommandExtensions::PuppetEnvironments.new)
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include HammerCLIForeman::ResourceSupportedTest

      option "--id", "ID", " ", :referenced_resource => 'organization'

      success_message _("Organization updated.")
      failure_message _("Could not update the organization")

      build_options

      extend_with(HammerCLIForeman::CommandExtensions::PuppetEnvironments.new)
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      include HammerCLIForeman::ResourceSupportedTest

      option "--id", "ID", " ", :referenced_resource => 'organization'

      success_message _("Organization deleted.")
      failure_message _("Could not delete the organization")

      build_options do |o|
        o.expand.primary(:organizations)
      end
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for an organization")

      success_message_for :update, _("Parameter [%{name}] updated to value [%{value}]")
      success_message_for :create, _("Parameter [%{name}] created with value [%{value}]")
      failure_message _("Could not set organization parameter")

      build_options
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for an organization")

      success_message _("Parameter [%{name}] deleted.")
      failure_message _("Could not delete organization parameter")

      build_options
    end


    HammerCLIForeman::AssociatingCommands::Hostgroup.extend_command(self)
    HammerCLIForeman::AssociatingCommands::PuppetEnvironment.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Domain.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Medium.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Subnet.extend_command(self)
    HammerCLIForeman::AssociatingCommands::ComputeResource.extend_command(self)
    HammerCLIForeman::AssociatingCommands::SmartProxy.extend_command(self)
    HammerCLIForeman::AssociatingCommands::User.extend_command(self)
    HammerCLIForeman::AssociatingCommands::ProvisioningTemplate.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Location.extend_command(self)

    autoload_subcommands
  end

end
