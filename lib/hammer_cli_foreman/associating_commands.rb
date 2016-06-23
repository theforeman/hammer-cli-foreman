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
        cmd_cls.desc(command.desc)
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
        desc _("Associate a hostgroup")

        success_message _("The hostgroup has been associated")
        failure_message _("Could not associate the hostgroup")
      end

      class RemoveHostgroupCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :hostgroups
        desc _("Disassociate a hostgroup")

        success_message _("The hostgroup has been disassociated")
        failure_message _("Could not disassociate the hostgroup")
      end
    end

    module Environment
      extend CommandExtension

      class AddEnvironmentCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :environments
        desc _("Associate an environment")

        success_message _("The environment has been associated")
        failure_message _("Could not associate the environment")
      end

      class RemoveEnvironmentCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :environments
        desc _("Disassociate an environment")

        success_message _("The environment has been disassociated")
        failure_message _("Could not disassociate the environment")
      end
    end

    module Domain
      extend CommandExtension

      class AddDomainCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :domains
        desc _("Associate a domain")

        success_message _("The domain has been associated")
        failure_message _("Could not associate the domain")
      end

      class RemoveDomainCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :domains
        desc _("Disassociate a domain")

        success_message _("The domain has been disassociated")
        failure_message _("Could not disassociate the domain")
      end
    end

    module Medium
      extend CommandExtension

      class AddMediumCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :media
        desc _("Associate a medium")

        success_message _("The medium has been associated")
        failure_message _("Could not associate the medium")
      end

      class RemoveMediumCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :media
        desc _("Disassociate a medium")

        success_message _("The medium has been disassociated")
        failure_message _("Could not disassociate the medium")
      end
    end

    module Subnet
      extend CommandExtension

      class AddSubnetCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :subnets
        desc _("Associate a subnet")

        success_message _("The subnet has been associated")
        failure_message _("Could not associate the subnet")
      end

      class RemoveSubnetCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :subnets
        desc _("Disassociate a subnet")

        success_message _("The subnet has been disassociated")
        failure_message _("Could not disassociate the subnet")
      end
    end

    module ComputeResource
      extend CommandExtension

      class AddComputeResourceCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :compute_resources
        desc _("Associate a compute resource")

        success_message _("The compute resource has been associated")
        failure_message _("Could not associate the compute resource")
      end

      class RemoveComputeResourceCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :compute_resources
        desc _("Disassociate a compute resource")

        success_message _("The compute resource has been disassociated")
        failure_message _("Could not disassociate the compute resource")
      end
    end

    module SmartProxy
      extend CommandExtension

      class AddSmartProxyCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :smart_proxies
        desc _("Associate a smart proxy")

        success_message _("The smart proxy has been associated")
        failure_message _("Could not associate the smart proxy")

        def associated_resource_name
          "smart-proxy"
        end
      end

      class RemoveSmartProxyCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :smart_proxies
        desc _("Disassociate a smart proxy")

        success_message _("The smart proxy has been disassociated")
        failure_message _("Could not disassociate the smart proxy")

        def associated_resource_name
          "smart-proxy"
        end
      end
    end

    module User
      extend CommandExtension

      class AddUserCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :users
        desc _("Associate an user")

        success_message _("The user has been associated")
        failure_message _("Could not associate the user")
      end

      class RemoveUserCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :users
        desc _("Disassociate an user")

        success_message _("The user has been disassociated")
        failure_message _("Could not disassociate the user")
      end
    end

    module Usergroup
      extend CommandExtension

      class AddUsergroupCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :usergroups
        desc _("Associate an user group")

        command_name 'add-user-group'

        success_message _("The user group has been associated")
        failure_message _("Could not associate the user group")
      end

      class RemoveUsergroupCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :usergroups
        desc _("Disassociate an user group")

        command_name 'remove-user-group'

        success_message _("The user group has been disassociated")
        failure_message _("Could not disassociate the user group")
      end
    end

    module ConfigTemplate
      extend CommandExtension

      class AddConfigTemplateCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :config_templates
        desc _("Associate a configuration template")

        success_message _("The configuration template has been associated")
        failure_message _("Could not associate the configuration template")
      end

      class RemoveConfigTemplateCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :config_templates
        desc _("Disassociate a configuration template")

        success_message _("The configuration template has been disassociated")
        failure_message _("Could not disassociate the configuration template")
      end
    end

    module Organization
      extend CommandExtension

      class AddOrganizationCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :organizations
        desc _("Associate an organization")

        success_message _("The organization has been associated")
        failure_message _("Could not associate the organization")
      end

      class RemoveOrganizationCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :organizations
        desc _("Disassociate an organization")

        success_message _("The organization has been disassociated")
        failure_message _("Could not disassociate the organization")
      end
    end

    module OperatingSystem
      extend CommandExtension

      class AddOSCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :operatingsystems
        desc _("Associate an operating system")

        success_message _("Operating system has been associated")
        failure_message _("Could not associate the operating system")
      end


      class RemoveOSCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :operatingsystems
        desc _("Disassociate an operating system")

        success_message _("Operating system has been disassociated")
        failure_message _("Could not disassociate the operating system")
      end
    end

    module Architecture
      extend CommandExtension

      class AddArchitectureCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :architectures
        desc _("Associate an architecture")

        success_message _("Architecture has been associated")
        failure_message _("Could not associate the architecture")
      end


      class RemoveArchitectureCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :architectures
        desc _("Disassociate an architecture")

        success_message _("Architecture has been disassociated")
        failure_message _("Could not disassociate the architecture")
      end
    end

    module PartitionTable
      extend CommandExtension

      class AddPartitionTableCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :ptables
        desc _("Associate a partition table")

        success_message _("Partition table has been associated")
        failure_message _("Could not associate the partition table")
      end


      class RemovePartitionTableCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :ptables
        desc _("Disassociate a partition table")

        success_message _("Partition table has been disassociated")
        failure_message _("Could not disassociate the partition table")
      end
    end

    module Role
      extend CommandExtension

      class AddRoleCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :roles
        desc _("Assign a user role")

        success_message _("User role has been assigned")
        failure_message _("Could not assign the user role")
      end


      class RemoveRoleCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :roles
        desc _("Remove a user role")

        success_message _("User role has been removed")
        failure_message _("Could not remove the user role")
      end
    end

    module Location
      extend CommandExtension

      class AddLocationCommand < HammerCLIForeman::AddAssociatedCommand
        associated_resource :locations
        desc _("Associate a location")

        success_message _("The location has been associated")
        failure_message _("Could not associate the location")
      end

      class RemoveLocationCommand < HammerCLIForeman::RemoveAssociatedCommand
        associated_resource :locations
        desc _("Disassociate a location")

        success_message _("The location has been disassociated")
        failure_message _("Could not disassociate the location")
      end
    end


  end
end


