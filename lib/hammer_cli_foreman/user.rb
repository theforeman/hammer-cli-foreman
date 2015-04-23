module HammerCLIForeman

  class User < HammerCLIForeman::Command

    resource :users

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :login, _("Login")
        field :full_name, _("Name")
        field :mail, _("Email")
      end

      def extend_data(user)
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :admin, _("Admin"), Fields::Boolean
        field :auth_source_internal, _("Authorized by"), Fields::Reference
        field :last_login_on, _("Last login"), Fields::Date
        custom_field Fields::Reference, :label => _("Default organization"), :path => [:default_organization]
        custom_field Fields::Reference, :label => _("Default location"), :path => [:default_location]
        HammerCLIForeman::References.roles(self)
        HammerCLIForeman::References.usergroups(self)
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      def extend_data(user)
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("User created")
      failure_message _("Could not create the user")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("User updated")
      failure_message _("Could not update the user")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("User deleted")
      failure_message _("Could not delete the user")

      build_options
    end

    HammerCLIForeman::AssociatingCommands::Role.extend_command(self)

    autoload_subcommands
  end

end


