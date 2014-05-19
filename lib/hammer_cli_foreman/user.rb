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

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'user', _("Manipulate users."), HammerCLIForeman::User
