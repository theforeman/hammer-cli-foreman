module HammerCLIForeman
  class PersonalAccessToken < HammerCLIForeman::Command
    resource :personal_access_tokens
    command_name "access-token"
    desc _("Manage personal access tokens")

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :active?, _("Active"), Fields::Boolean
        field :expires_at, _("Expires at"), Fields::Date
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Personal access token [%{name}] created:\n%{token_value}")
      failure_message _("Could not create personal access token")

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :created_at, _("Created at"), Fields::Date
        field :last_used_at, _("Last used at"), Fields::Date
      end

      build_options
    end

    class RevokeCommand < HammerCLIForeman::DeleteCommand
      command_name 'revoke'

      success_message _("Personal access token [%{name}] revoked.")
      failure_message _("Could not revoke personal access token")

      build_options
    end

    autoload_subcommands
  end
end
