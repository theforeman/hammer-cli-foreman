require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class User < HammerCLI::AbstractCommand
    class ListCommand < HammerCLI::Apipie::ReadCommand
      resource ForemanApi::Resources::User, "index"

      heading "User list"
      output do
        from "user" do
          field :id, "Id"
          field :login, "Login"
        end
        field :user, "Name", HammerCLI::Output::Fields::Joint, :attributes => [:firstname, :lastname]
        from "user" do
          field :mail, "Email"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLI::Apipie::ReadCommand

      resource ForemanApi::Resources::User, "show"

      heading "User info"
      output ListCommand.output_definition do
        from "user" do
          field :last_login_on, "Last login", HammerCLI::Output::Fields::Date
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
      end

      option "--id", "ID", "resource id", :required => true

    end


    class CreateCommand < HammerCLI::Apipie::WriteCommand

      success_message "User created"
      failure_message "Could not create the user"
      resource ForemanApi::Resources::User, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLI::Apipie::WriteCommand

      success_message "User updated"
      failure_message "Could not update the user"
      resource ForemanApi::Resources::User, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "User deleted"
      failure_message "Could not delete the user"
      resource ForemanApi::Resources::User, "destroy"

      apipie_options
    end

    subcommand "list", "List users.", HammerCLIForeman::User::ListCommand
    subcommand "info", "Detailed info about an user.", HammerCLIForeman::User::InfoCommand
    subcommand "create", "Create new user.", HammerCLIForeman::User::CreateCommand
    subcommand "update", "Update an user.", HammerCLIForeman::User::UpdateCommand
    subcommand "delete", "Delete an user.", HammerCLIForeman::User::DeleteCommand
  end

end

HammerCLI::MainCommand.subcommand 'user', "Manipulate Foreman's users.", HammerCLIForeman::User

