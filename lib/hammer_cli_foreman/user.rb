require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class User < HammerCLI::Apipie::Command
    resource ForemanApi::Resources::User

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, "Id"
        field :login, "Login"
        field :full_name, "Name"
        field :mail, "Email"
      end

      def extend_data(user)
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      identifiers :id

      output ListCommand.output_definition do
        field :last_login_on, "Last login", Fields::Date
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
      end

      def extend_data(user)
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "User created"
      failure_message "Could not create the user"
      resource ForemanApi::Resources::User, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      identifiers :id

      success_message "User updated"
      failure_message "Could not update the user"
      resource ForemanApi::Resources::User, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id

      success_message "User deleted"
      failure_message "Could not delete the user"
      resource ForemanApi::Resources::User, "destroy"

      apipie_options
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'user', "Manipulate users.", HammerCLIForeman::User

