module HammerCLIForeman

  class Model < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Model

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :vendor_class, _("Vendor class")
        field :hardware_model, _("HW model")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :info, _("Info")
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Hardware model created")
      failure_message _("Could not create the hardware model")

      apipie_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Hardware model deleted")
      failure_message _("Could not delete the hardware model")

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Hardware model updated")
      failure_message _("Could not update the hardware model")

      apipie_options
    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'model', _("Manipulate hardware models."), HammerCLIForeman::Model

