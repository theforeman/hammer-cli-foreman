require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/associating_commands'

module HammerCLIForeman

  class Medium < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Medium

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        from "medium" do
          field :id, "Id"
          field :name, "Name"
          field :path, "Path"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        from "medium" do
          field :os_family, "OS Family"
          field :operatingsystem_ids, "OS IDs", HammerCLI::Output::Fields::List
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Installation medium created"
      failure_message "Could not create the installation medium"

      apipie_options

      #FIXME: remove OS ids option and custom request_params once it's added to foreman's apipie docs
      option "--operatingsystem-ids", "OSIDS", "os ids", &HammerCLI::OptionFormatters.method(:list)

      def request_params
        params = super
        params['medium']['operatingsystem_ids'] = operatingsystem_ids
        params
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Installation medium updated"
      failure_message "Could not update the installation media"

      apipie_options

      #FIXME: remove OS ids option and custom request_params once it's added to foreman's apipie docs
      option "--operatingsystem-ids", "OSIDS", "os ids", &HammerCLI::OptionFormatters.method(:list)

      def request_params
        params = super
        params['medium']['operatingsystem_ids'] = operatingsystem_ids
        params
      end
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

HammerCLI::MainCommand.subcommand 'medium', "Manipulate Foreman's installation media.", HammerCLIForeman::Medium

