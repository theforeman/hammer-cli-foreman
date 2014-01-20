module HammerCLIForeman

  class Medium < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Medium

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, "Id"
        field :name, "Name"
        field :path, "Path"
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :os_family, "OS Family"
        field :operatingsystem_ids, "OS IDs", Fields::List
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Installation medium created"
      failure_message "Could not create the installation medium"

      apipie_options

    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Installation medium updated"
      failure_message "Could not update the installation media"

      apipie_options

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Installation medium deleted"
      failure_message "Could not delete the installation media"

      apipie_options
    end


    include HammerCLIForeman::AssociatingCommands::OperatingSystem

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'medium', "Manipulate installation media.", HammerCLIForeman::Medium

