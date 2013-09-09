require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class User < HammerCLI::AbstractCommand
    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::User, "index"

      def retrieve_data
        data = super
        data.map do |d|
          d["user"]["full_name"] = [d["user"]["firstname"], d["user"]["lastname"]].join(' ')
          d
        end
      end

      output do
        from "user" do
          field :id, "Id"
          field :login, "Login"
          field :full_name, "Name"
          field :mail, "Email"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      resource ForemanApi::Resources::User, "show"
      identifiers :id

      def retrieve_data
        data = super
        data["user"]["full_name"] = [data["user"]["firstname"], data["user"]["lastname"]].join(' ')
        data
      end

      output ListCommand.output_definition do
        from "user" do
          field :last_login_on, "Last login", HammerCLI::Output::Fields::Date
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
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

HammerCLI::MainCommand.subcommand 'user', "Manipulate Foreman's users.", HammerCLIForeman::User

