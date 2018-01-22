module HammerCLIForeman

  class Medium < HammerCLIForeman::Command

    resource :media

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :path, _("Path")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :os_family, _("OS Family")
        HammerCLIForeman::References.operating_systems(self)
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Installation medium created")
      failure_message _("Could not create the installation medium")

      build_options

    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Installation medium updated")
      failure_message _("Could not update the installation media")

      build_options

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Installation medium deleted")
      failure_message _("Could not delete the installation media")

      build_options
    end


    HammerCLIForeman::AssociatingCommands::OperatingSystem.extend_command(self)

    autoload_subcommands
  end

end
