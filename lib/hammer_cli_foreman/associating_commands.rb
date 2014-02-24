module HammerCLIForeman
  module AssociatingCommands

    module Hostgroup
      class AddHostgroupCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Hostgroup
        apipie_options
      end

      class RemoveHostgroupCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Hostgroup
        apipie_options
      end
    end

    module Environment
      class AddEnvironmentCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Environment
        apipie_options
      end

      class RemoveEnvironmentCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Environment
        apipie_options
      end
    end

    module Domain
      class AddDomainCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Domain
        apipie_options
      end

      class RemoveDomainCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Domain
        apipie_options
      end
    end

    module Medium
      class AddMediumCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Medium
        apipie_options
      end

      class RemoveMediumCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Medium
        apipie_options
      end
    end

    module Subnet
      class AddSubnetCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Subnet
        apipie_options
      end

      class RemoveSubnetCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Subnet
        apipie_options
      end
    end

    module ComputeResource
      class AddComputeResourceCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::ComputeResource
        apipie_options
      end

      class RemoveComputeResourceCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::ComputeResource
        apipie_options
      end
    end

    module SmartProxy
      class AddSmartProxyCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::SmartProxy
        apipie_options

        def associated_resource_name
          "smart_proxy"
        end
      end

      class RemoveSmartProxyCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::SmartProxy
        apipie_options

        def associated_resource_name
          "smart_proxy"
        end
      end
    end

    module User
      class AddUserCommand < HammerCLIForeman::AddAssociatedCommand
        associated_identifiers :id

        associated_resource ForemanApi::Resources::User
        apipie_options

        success_message "The user has been associated"
        failure_message "Could not associate the user"
      end

      class RemoveUserCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_identifiers :id

        associated_resource ForemanApi::Resources::User
        apipie_options

        success_message "The user has been disassociated"
        failure_message "Could not disassociate the user"
      end
    end

    module ConfigTemplate
      class AddConfigTemplateCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::ConfigTemplate
        apipie_options
      end

      class RemoveConfigTemplateCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::ConfigTemplate
        apipie_options
      end
    end

    module Organization
      class AddOrganizationCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Organization
        apipie_options
      end

      class RemoveOrganizationCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Organization
        apipie_options
      end
    end

    module OperatingSystem
      class AddOSCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::OperatingSystem

        associated_identifiers :id
        apipie_options

        success_message "Operating system has been associated"
        failure_message "Could not associate the operating system"
      end


      class RemoveOSCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::OperatingSystem

        associated_identifiers :id
        apipie_options

        success_message "Operating system has been disassociated"
        failure_message "Could not disassociate the operating system"
      end
    end

    module Architecture
      class AddArchitectureCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Architecture
        apipie_options

        success_message "Architecture has been associated"
        failure_message "Could not associate the architecture"
      end


      class RemoveArchitectureCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Architecture
        apipie_options

        success_message "Architecture has been disassociated"
        failure_message "Could not disassociate the architecture"
      end
    end

    module PartitionTable
      class AddPartitionTableCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource ForemanApi::Resources::Ptable
        apipie_options

        success_message "Partition table has been associated"
        failure_message "Could not associate the partition table"
      end


      class RemovePartitionTableCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource ForemanApi::Resources::Ptable
        apipie_options

        success_message "Partition table has been disassociated"
        failure_message "Could not disassociate the partition table"
      end
    end


  end
end


