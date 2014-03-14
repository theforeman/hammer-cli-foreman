module HammerCLIForeman

  class User < HammerCLI::Apipie::Command
    resource ForemanApi::Resources::User

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

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      identifiers :id, :login

      option '--login', 'LOGIN', _("User login") do |value|
        name_to_id(value, "login", resource)
      end

      output ListCommand.output_definition do
        field :last_login_on, _("Last login"), Fields::Date
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      def extend_data(user)
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("User created")
      failure_message _("Could not create the user")
      resource ForemanApi::Resources::User, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      identifiers :id, :login

      option '--login', 'LOGIN', _("User login") do |value|
        name_to_id(value, "login", resource)
      end

      success_message _("User updated")
      failure_message _("Could not update the user")
      resource ForemanApi::Resources::User, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id, :login

      option '--login', 'LOGIN', _("User login") do |value|
        name_to_id(value, "login", resource)
      end

      success_message _("User deleted")
      failure_message _("Could not delete the user")
      resource ForemanApi::Resources::User, "destroy"

      apipie_options
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'user', _("Manipulate users."), HammerCLIForeman::User

