
module HammerCLIForeman

  class VirtualMachine < HammerCLIForeman::Command
    resource :compute_resources
    command_name 'virtual_machine'
    desc _("View and manage compute resource's virtual machines")

    class PowerVmCommand < HammerCLIForeman::Command
      action :power_vm
      command_name 'power'

      success_message _("Virtual machine is powering.")
      failure_message _("Could not power the virtual machine")

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      action :show_vm

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      def print_data(data)
        provider = ::HammerCLIForeman.compute_resources[data['provider'].downcase]
        if provider
          output_definition.fields.concat(provider.provider_vm_specific_fields || [])
          super(data)
        end
      end

      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      action :destroy_vm

      success_message _("Virtual machine deleted.")
      failure_message _("Could not delete the virtual machine")

      build_options
    end

    autoload_subcommands
  end

end

