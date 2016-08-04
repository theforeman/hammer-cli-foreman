require 'hammer_cli_foreman/external_usergroup'

module HammerCLIForeman

  class Usergroup < HammerCLIForeman::Command

    resource :usergroups

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :admin, _("Admin"), Fields::Boolean
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        HammerCLIForeman::References.users(self)
        HammerCLIForeman::References.usergroups(self)
        HammerCLIForeman::References.external_usergroups(self)
        HammerCLIForeman::References.roles(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("User group [%<name>s] created")
      failure_message _("Could not create the user group")

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("User group [%<name>s] updated")
      failure_message _("Could not update the user group")

      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("User group [%<name>s] deleted")
      failure_message _("Could not delete the user group")

      build_options
    end

    HammerCLIForeman::AssociatingCommands::Role.extend_command(self)
    HammerCLIForeman::AssociatingCommands::User.extend_command(self)
    HammerCLIForeman::AssociatingCommands::Usergroup.extend_command(self)

    autoload_subcommands
    subcommand 'external', HammerCLIForeman::ExternalUsergroup.desc, HammerCLIForeman::ExternalUsergroup
  end

end
