module HammerCLIForeman

  class Model < HammerCLIForeman::Command

    resource :models

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :vendor_class, _("Vendor class")
        field :hardware_model, _("HW model")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :info, _("Info")
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Hardware model created.")
      failure_message _("Could not create the hardware model")

      option '--name', 'NAME', _('Name of the hardware model'), :required => true
      option '--info', 'INFO', _('Additional information about the hardware model')
      option '--vendor-class', 'VENDOR_CLASS', _('Vendor class of the hardware model')
      option '--hardware-model', 'HARDWARE_MODEL', _('Hardware model identifier')

      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Hardware model deleted.")
      failure_message _("Could not delete the hardware model")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Hardware model updated.")
      failure_message _("Could not update the hardware model")

      option '--id', 'ID', _('Hardware model numeric id to search by')
      option '--name', 'NAME', _('Hardware model name to search by')
      option '--new-name', 'NEW_NAME', _('New name for the hardware model')
      option '--info', 'INFO', _('Additional information about the hardware model')
      option '--vendor-class', 'VENDOR_CLASS', _('Vendor class of the hardware model')
      option '--hardware-model', 'HARDWARE_MODEL', _('Hardware model identifier')

      build_options
    end


    autoload_subcommands
  end

end
