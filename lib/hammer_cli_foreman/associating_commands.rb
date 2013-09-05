require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman
  module AssociatingCommands

    module Hostgroup
      class AddHostgroupCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Hostgroup
      end

      class RemoveHostgroupCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Hostgroup
      end
    end

    module Environment
      class AddEnvironmentCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Environment
      end

      class RemoveEnvironmentCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Environment
      end
    end

    module Domain
      class AddDomainCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Domain
      end

      class RemoveDomainCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Domain
      end
    end

    module Medium
      class AddMediumCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Medium
      end

      class RemoveMediumCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Medium
      end
    end

    module Subnet
      class AddSubnetCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Subnet
      end

      class RemoveSubnetCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Subnet
      end
    end

    module ComputeResource
      class AddComputeResourceCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::ComputeResource
      end

      class RemoveComputeResourceCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::ComputeResource
      end
    end

    module SmartProxy
      class AddSmartProxyCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::SmartProxy

        def associated_resource_name
          "smart_proxy"
        end
      end

      class RemoveSmartProxyCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::SmartProxy

        def associated_resource_name
          "smart_proxy"
        end
      end
    end

    module User
      class AddUserCommand < HammerCLIForeman::AddAssociatedCommand
        associated_identifiers :id

        associated_resource ForemanApi::Resources::User
      end

      class RemoveUserCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_identifiers :id

        associated_resource ForemanApi::Resources::User
      end
    end

    module ConfigTemplate
      class AddConfigTemplateCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::ConfigTemplate
      end

      class RemoveConfigTemplateCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::ConfigTemplate
      end
    end

    module Organization
      class AddOrganizationCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Organization
      end

      class RemoveOrganizationCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Organization
      end
    end

    module OperatingSystem
      class AddOSCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::OperatingSystem

        associated_identifiers :id

        success_message "Operating system has been associated"
        failure_message "Could not associate the operating system"
      end


      class RemoveOSCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::OperatingSystem

        associated_identifiers :id

        success_message "Operating system has been disassociated"
        failure_message "Could not disassociate the operating system"
      end
    end

    module Architecture
      class AddArchitectureCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Architecture

        success_message "Architecture has been associated"
        failure_message "Could not associate the architecture"
      end


      class RemoveArchitectureCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Architecture

        success_message "Architecture has been disassociated"
        failure_message "Could not disassociate the architecture"
      end
    end

    module PartitionTable
      class AddPartitionTableCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Ptable

        success_message "Partition table has been associated"
        failure_message "Could not associate the partition table"
      end


      class RemovePartitionTableCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Ptable

        success_message "Partition table has been disassociated"
        failure_message "Could not disassociate the partition table"
      end
    end


  end
end


