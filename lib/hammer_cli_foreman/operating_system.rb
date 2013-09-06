require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/associating_commands'

module HammerCLIForeman

  class OperatingSystem < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::OperatingSystem

    class ListCommand < HammerCLIForeman::ListCommand

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

      identifiers :id, :label

      heading "Operating system info"
      output ListCommand.output_definition do
        from "operatingsystem" do
          field :media_names, "Installation media", HammerCLI::Output::Fields::List
          field :architecture_names, "Architectures", HammerCLI::Output::Fields::List
          field :ptable_names, "Partition tables", HammerCLI::Output::Fields::List
          field :config_template_names, "Config templates", HammerCLI::Output::Fields::List
        end
        collection :parameters, "Parameters" do
          field :parameter, nil, HammerCLI::Output::Fields::KeyValue
        end
      end

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

      #FIXME: replace with apipie_options when they are added to the api docs
      option "--architecture-ids", "ARCH_IDS", "set associated architectures", &HammerCLI::OptionFormatters.method(:list)
      option "--config-template-ids", "CONFIG_TPL_IDS", "set associated templates", &HammerCLI::OptionFormatters.method(:list)
      option "--medium-ids", "MEDIUM_IDS", "set associated installation media", &HammerCLI::OptionFormatters.method(:list)
      option "--ptable-ids", "PTABLE_IDS", "set associated partition tables", &HammerCLI::OptionFormatters.method(:list)

      success_message "Operating system created"
      failure_message "Could not create the operating system"

      def request_params
        params = method_options
        params["operatingsystem"]["architecture_ids"] = architecture_ids if architecture_ids
        params["operatingsystem"]["config_template_ids"] = config_template_ids if config_template_ids
        params["operatingsystem"]["medium_ids"] = medium_ids if medium_ids
        params["operatingsystem"]["ptable_ids"] = ptable_ids if ptable_ids
        params
      end

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      #FIXME: replace with apipie_options when they are added to the api docs
      option "--architecture-ids", "ARCH_IDS", "set associated architectures", &HammerCLI::OptionFormatters.method(:list)
      option "--config-template-ids", "CONFIG_TPL_IDS", "set associated templates", &HammerCLI::OptionFormatters.method(:list)
      option "--medium-ids", "MEDIUM_IDS", "set associated installation media", &HammerCLI::OptionFormatters.method(:list)
      option "--ptable-ids", "PTABLE_IDS", "set associated partition tables", &HammerCLI::OptionFormatters.method(:list)

      identifiers :id, :label

      success_message "Operating system updated"
      failure_message "Could not update the operating system"

      def request_params
        params = method_options
        params["operatingsystem"]["architecture_ids"] = architecture_ids if architecture_ids
        params["operatingsystem"]["config_template_ids"] = config_template_ids if config_template_ids
        params["operatingsystem"]["medium_ids"] = medium_ids if medium_ids
        params["operatingsystem"]["ptable_ids"] = ptable_ids if ptable_ids
        params
      end

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id, :label

      success_message "Operating system deleted"
      failure_message "Could not delete the operating system"

      apipie_options
    end

    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      desc "Create or update parameter for an operating system."

      #FIXME: add option --os-label when api supports it
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

      desc "Delete parameter for an operating system."

      #FIXME: add option --os-label when api supports it
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


    include HammerCLIForeman::AssociatingCommands::Architecture
    include HammerCLIForeman::AssociatingCommands::ConfigTemplate
    include HammerCLIForeman::AssociatingCommands::PartitionTable


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'os', "Manipulate Foreman's operating system.", HammerCLIForeman::OperatingSystem

