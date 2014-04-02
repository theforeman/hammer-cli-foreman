module HammerCLIForeman

  class Medium < HammerCLIForeman::Command

    resource :media

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :path, _("Path")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :os_family, _("OS Family")
        field :operatingsystem_ids, _("OS IDs"), Fields::List
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      def extend_data(res)
        res['operatingsystem_ids'] = res['operatingsystems'].map { |e| e["id"] } rescue []
        res
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Installation medium created")
      failure_message _("Could not create the installation medium")

      apipie_options

    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _("Installation medium updated")
      failure_message _("Could not update the installation media")

      apipie_options

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Installation medium deleted")
      failure_message _("Could not delete the installation media")

      apipie_options
    end


    include HammerCLIForeman::AssociatingCommands::OperatingSystem

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'medium', _("Manipulate installation media."), HammerCLIForeman::Medium

