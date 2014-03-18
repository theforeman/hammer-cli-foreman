module HammerCLIForeman
  module AssociatingCommands

    module CommandExtension

      def extend_command(base_command)
        commands = self.constants.map {|c| self.const_get(c)}.select {|c| c < HammerCLI::AbstractCommand }

        commands.each do |cmd|
          plug_command(cmd, base_command)
        end
      end

      def plug_command(command, base_command)
        cmd_name = base_name(command)
        base_name = base_name(base_command)

        name = base_name + cmd_name

        cmd_cls = Class.new(command)
        base_command.const_set(name, cmd_cls)

        cmd_cls.resource(base_command.resource.name)
        #TODO: update messages to inherit from parents
        cmd_cls.success_message(command.success_message)
        cmd_cls.failure_message(command.failure_message)
        cmd_cls.build_options
      end

      def base_name(cls)
        cls.name.split("::")[-1]
      end
    end

    module Hostgroup
      extend CommandExtension

      class AddHostgroupCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :hostgroups
      end

      class RemoveHostgroupCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :hostgroups
      end
    end

    module Environment
      extend CommandExtension

      class AddEnvironmentCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :environments
      end

      class RemoveEnvironmentCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :environments
      end
    end

    module Domain
      extend CommandExtension

      class AddDomainCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :domains
      end

      class RemoveDomainCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :domains
      end
    end

    module Medium
      extend CommandExtension

      class AddMediumCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :media
      end

      class RemoveMediumCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :media
      end
    end

    module Subnet
      extend CommandExtension

      class AddSubnetCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :subnets
      end

      class RemoveSubnetCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :subnets
      end
    end

    module ComputeResource
      extend CommandExtension

      class AddComputeResourceCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :compute_resources
      end

      class RemoveComputeResourceCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :compute_resources
      end
    end

    module SmartProxy
      extend CommandExtension

      class AddSmartProxyCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :smart_proxies

        def associated_resource_name
          "smart-proxy"
        end
      end

      class RemoveSmartProxyCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :smart_proxies

        def associated_resource_name
          "smart-proxy"
        end
      end
    end

    module User
      extend CommandExtension

      class AddUserCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :users

        success_message "The user has been associated"
        failure_message "Could not associate the user"
      end

      class RemoveUserCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :users

        success_message "The user has been disassociated"
        failure_message "Could not disassociate the user"
      end
    end

    module ConfigTemplate
      extend CommandExtension

      class AddConfigTemplateCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :config_templates
      end

      class RemoveConfigTemplateCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :config_templates
      end
    end

    module Organization
      extend CommandExtension

      class AddOrganizationCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :organizations
      end

      class RemoveOrganizationCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :organizations
      end
    end

    module OperatingSystem
      extend CommandExtension

      class AddOSCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :operatingsystems

        success_message _("Operating system has been associated")
        failure_message _("Could not associate the operating system")
      end


      class RemoveOSCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :operatingsystems

        success_message _("Operating system has been disassociated")
        failure_message _("Could not disassociate the operating system")
      end
    end

    module Architecture
      extend CommandExtension

      class AddArchitectureCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :architectures

        success_message _("Architecture has been associated")
        failure_message _("Could not associate the architecture")
      end


      class RemoveArchitectureCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :architectures

        success_message _("Architecture has been disassociated")
        failure_message _("Could not disassociate the architecture")
      end
    end

    module PartitionTable
      extend CommandExtension

      class AddPartitionTableCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :ptables

        success_message _("Partition table has been associated")
        failure_message _("Could not associate the partition table")
      end


      class RemovePartitionTableCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :ptables

        success_message _("Partition table has been disassociated")
        failure_message _("Could not disassociate the partition table")
      end
    end


  end
end


