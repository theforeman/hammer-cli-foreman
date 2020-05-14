module HammerCLIForeman

  class User < HammerCLIForeman::Command

    resource :users

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :login, _("Login")
        field :full_name, _("Name")
        field :mail, _("Email")
        field :admin, _("Admin"), Fields::Boolean
        field :last_login_on, _("Last login"), Fields::Date
        field nil, _("Authorized by"), Fields::SingleReference, :key => :auth_source
      end

      def extend_data(user)
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :effective_admin, _("Effective admin"), Fields::Boolean
        field :locale, _("Locale")
        field :timezone, _("Timezone")
        field :description, _("Description")
        custom_field Fields::Reference, :label => _("Default organization"), :path => [:default_organization]
        custom_field Fields::Reference, :label => _("Default location"), :path => [:default_location]
        HammerCLIForeman::References.roles(self)
        HammerCLIForeman::References.usergroups(self)
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      def extend_data(user)
        user["locale"] ||= _('default') if user.has_key?("locale")
        user["timezone"] ||= _('default') if user.has_key?("timezone")
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user["cached_usergroups"] = user.fetch('cached_usergroups', []) - user["usergroups"]
        user
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("User [%{login}] created.")
      failure_message _("Could not create the user")

      extend_with(HammerCLIForeman::CommandExtensions::User.new)

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("User [%{login}] updated.")
      failure_message _("Could not update the user")

      extend_with(HammerCLIForeman::CommandExtensions::User.new)

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("User [%{login}] deleted.")
      failure_message _("Could not delete the user")

      build_options
    end

    HammerCLIForeman::AssociatingCommands::Role.extend_command(self)
    lazy_subcommand('ssh-keys', _("Managing User SSH Keys."),
      'HammerCLIForeman::SSHKeys', 'hammer_cli_foreman/ssh_keys'
    )
    lazy_subcommand('access-token', _("Managing personal access tokens"),
      'HammerCLIForeman::PersonalAccessToken', 'hammer_cli_foreman/personal_access_token'
    )
    lazy_subcommand('mail-notification', _("Managing personal mail notifications"),
                    'HammerCLIForeman::UserMailNotification', 'hammer_cli_foreman/user_mail_notification'
    )
    autoload_subcommands
  end

end
