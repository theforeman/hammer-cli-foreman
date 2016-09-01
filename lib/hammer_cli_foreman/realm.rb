module HammerCLIForeman
  class Realm < HammerCLIForeman::Command

    resource :realms

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :realm_proxy_id, _("Realm proxy id")
        field :realm_type, _("Realm type")
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Realm [%{name}] created")
      failure_message _("Could not create the realm")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Realm [%{name}] updated")
      failure_message _("Could not update the realm")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Realm [%{name}] deleted")
      failure_message _("Could not delete the realm")

      build_options
    end

    autoload_subcommands
  end
end
