module HammerCLIForeman
  module AssociatingCommands

    module Hostgroup
      class AddHostgroupCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :hostgroups
        apipie_options
      end

      class RemoveHostgroupCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :hostgroups
        apipie_options
      end
    end

    module Environment
      class AddEnvironmentCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :environments
        apipie_options
      end

      class RemoveEnvironmentCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :environments
        apipie_options
      end
    end

    module Domain
      class AddDomainCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :domains
        apipie_options
      end

      class RemoveDomainCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :domains
        apipie_options
      end
    end

    module Medium
      class AddMediumCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :media
        apipie_options
      end

      class RemoveMediumCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :media
        apipie_options
      end
    end

    module Subnet
      class AddSubnetCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :subnets
        apipie_options
      end

      class RemoveSubnetCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :subnets
        apipie_options
      end
    end

    module ComputeResource
      class AddComputeResourceCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :compute_resources
        apipie_options
      end

      class RemoveComputeResourceCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :compute_resources
        apipie_options
      end
    end

    module SmartProxy
      class AddSmartProxyCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :smart_proxies
        apipie_options

        def associated_resource_name
          "smart_proxy"
        end
      end

      class RemoveSmartProxyCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :smart_proxies
        apipie_options

        def associated_resource_name
          "smart_proxy"
        end
      end
    end

    module User
      class AddUserCommand < HammerCLIForeman::AddAssociatedCommand
        associated_identifiers :id

        associated_resource :users
        apipie_options

        success_message "The user has been associated"
        failure_message "Could not associate the user"
      end

      class RemoveUserCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_identifiers :id

        associated_resource :users
        apipie_options

        success_message "The user has been disassociated"
        failure_message "Could not disassociate the user"
      end
    end

    module ConfigTemplate
      class AddConfigTemplateCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :config_templates
        apipie_options
      end

      class RemoveConfigTemplateCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :config_templates
        apipie_options
      end
    end

    module Organization
      class AddOrganizationCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :organizations
        apipie_options
      end

      class RemoveOrganizationCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :organizations
        apipie_options
      end
    end

    module OperatingSystem
      class AddOSCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :operatingsystems

        associated_identifiers :id
        apipie_options

        success_message _("Operating system has been associated")
        failure_message _("Could not associate the operating system")
      end


      class RemoveOSCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :operatingsystems

        associated_identifiers :id
        apipie_options

        success_message _("Operating system has been disassociated")
        failure_message _("Could not disassociate the operating system")
      end
    end

    module Architecture
      class AddArchitectureCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :architectures
        apipie_options

        success_message _("Architecture has been associated")
        failure_message _("Could not associate the architecture")
      end


      class RemoveArchitectureCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :architectures
        apipie_options

        success_message _("Architecture has been disassociated")
        failure_message _("Could not disassociate the architecture")
      end
    end

    module PartitionTable
      class AddPartitionTableCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :ptables
        apipie_options

        success_message _("Partition table has been associated")
        failure_message _("Could not associate the partition table")
      end


      class RemovePartitionTableCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :ptables
        apipie_options

        success_message _("Partition table has been disassociated")
        failure_message _("Could not disassociate the partition table")
      end
    end


  end
end


