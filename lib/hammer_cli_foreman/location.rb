require 'hammer_cli'
require 'foreman_api'
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


    class AddHostgroupCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Hostgroup
    end


    class RemoveHostgroupCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Hostgroup
    end


    class AddEnvironmentCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Environment
    end


    class RemoveEnvironmentCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Environment
    end


    class AddDomainCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Domain
    end


    class RemoveDomainCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Domain
    end


    class AddMediumCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Medium
    end


    class RemoveMediumCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Medium
    end


    class AddSubnetCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Subnet
    end


    class RemoveSubnetCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Subnet
    end


    class AddComputeResourceCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::ComputeResource
    end


    class RemoveComputeResourceCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::ComputeResource
    end


    class AddSmartProxyCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::SmartProxy
    end


    class RemoveSmartProxyCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::SmartProxy
    end


    class AddUserCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::User
    end


    class RemoveUserCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::User
    end


    class AddConfigTemplateCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::ConfigTemplate
    end


    class RemoveConfigTemplateCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::ConfigTemplate
    end


    class AddOrganizationCommand < HammerCLIForeman::AddAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Organization
    end


    class RemoveOrganizationCommand < HammerCLIForeman::RemoveAssociatedCommand
      resource ForemanApi::Resources::Location
      associated_resource ForemanApi::Resources::Organization
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'location', "Manipulate Foreman's locations.", HammerCLIForeman::Location

