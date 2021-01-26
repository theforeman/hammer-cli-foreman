module HammerCLIForeman

  class Architecture < HammerCLIForeman::Command

    resource :architectures

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        HammerCLIForeman::References.operating_systems(self)
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Architecture created.")
      failure_message _("Could not create the architecture")

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Architecture deleted.")
      failure_message _("Could not delete the architecture")

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Architecture updated.")
      failure_message _("Could not update the architecture")

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end

    HammerCLIForeman::AssociatingCommands::OperatingSystem.extend_command(self)

    autoload_subcommands
  end

end
