require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class OperatingSystem < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::OperatingSystem, "index"

      heading "Operating systems"
      output do
        from "operatingsystem" do
          field :id, "Id"
        end
        field :operatingsystem, "Name", HammerCLI::Output::Fields::OSName
        from "operatingsystem" do
          field :release_name, "Release name"
          field :family, "Family"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      resource ForemanApi::Resources::OperatingSystem, "show"

      identifiers :id, :label

      heading "Operating system info"
      output ListCommand.output_definition do
        from "operatingsystem" do

          field :media_names, "Installation media", HammerCLI::Output::Fields::List
          field :architecture_names, "Architectures", HammerCLI::Output::Fields::List
          field :ptable_names, "Partition tables", HammerCLI::Output::Fields::List
          field :config_template_names, "Config templates", HammerCLI::Output::Fields::List

          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
        collection :parameters, "Parameters" do
          field :parameter, nil, HammerCLI::Output::Fields::KeyValue
        end
      end

      #FIXME: add timestamps to the api
      #FIXME: remove custom retrieve_data after the api has support for listing names
      def retrieve_data
        os = super
        os["operatingsystem"]["media_names"] = os["operatingsystem"]["media"].collect{|m| m["medium"]["name"] } rescue []
        os["operatingsystem"]["architecture_names"] = os["operatingsystem"]["architectures"].collect{|m| m["architecture"]["name"] } rescue []
        os["operatingsystem"]["ptable_names"] = os["operatingsystem"]["ptables"].collect{|m| m["ptable"]["name"] } rescue []
        os["operatingsystem"]["config_template_names"] = os["operatingsystem"]["config_templates"].collect{|m| m["config_template"]["name"] } rescue []
        os["parameters"] = HammerCLIForeman::Parameter.get_parameters resource_config, os
        os
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Operating system created"
      failure_message "Could not create the operating system"
      resource ForemanApi::Resources::OperatingSystem, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      identifiers :id, :label

      success_message "Operating system updated"
      failure_message "Could not update the operating system"
      resource ForemanApi::Resources::OperatingSystem, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id, :label

      success_message "Operating system deleted"
      failure_message "Could not delete the operating system"
      resource ForemanApi::Resources::OperatingSystem, "destroy"

      apipie_options
    end

    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      #FIXME: add option --os-name when api supports it
      option "--os-id", "OS_ID", "id of the operating system the parameter is being set for"

      success_message_for :update, "Operating system parameter updated"
      success_message_for :create, "New operating system parameter created"
      failure_message "Could not set operating system parameter"

      def validate_options
        super
        validator.any(:os_id).required
      end

      def base_action_params
        {
          "operatingsystem_id" => os_id
        }
      end
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand

      #FIXME: add option --os-name when api supports it
      option "--os-id", "OS_ID", "id of the operating system the parameter is being deleted for"
      success_message "operating system parameter deleted"

      def validate_options
        super
        validator.any(:os_id).required
      end

      def base_action_params
        {
          "operatingsystem_id" => os_id
        }
      end
    end

    subcommand "list", "List operating systems.", HammerCLIForeman::OperatingSystem::ListCommand
    subcommand "info", "Detailed info about an operating system.", HammerCLIForeman::OperatingSystem::InfoCommand
    subcommand "create", "Create new operating system.", HammerCLIForeman::OperatingSystem::CreateCommand
    subcommand "update", "Update an operating system.", HammerCLIForeman::OperatingSystem::UpdateCommand
    subcommand "delete", "Delete an operating system.", HammerCLIForeman::OperatingSystem::DeleteCommand
    subcommand "set_parameter", "Create or update parameter for an operating system.", HammerCLIForeman::OperatingSystem::SetParameterCommand
    subcommand "delete_parameter", "Delete parameter for an operating system.", HammerCLIForeman::OperatingSystem::DeleteParameterCommand
  end

end

HammerCLI::MainCommand.subcommand 'os', "Manipulate Foreman's operating system.", HammerCLIForeman::OperatingSystem

