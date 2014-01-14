require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/associating_commands'

module HammerCLIForeman

  class OperatingSystem < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::OperatingSystem

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, "Id"
        field :_os_name, "Name", Fields::OSName
        field :release_name, "Release name"
        field :family, "Family"
      end

      def extend_data(os)
        os["_os_name"] = Hash[os.select { |k, v| ["name", "major", "minor"].include? k }]
        os
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      identifiers :id, :label

      output ListCommand.output_definition do
        field :media_names, "Installation media", Fields::List
        field :architecture_names, "Architectures", Fields::List
        field :ptable_names, "Partition tables", Fields::List
        field :config_template_names, "Config templates", Fields::List
        collection :parameters, "Parameters" do
          field nil, nil, Fields::KeyValue
        end
      end

      #FIXME: remove custom retrieve_data after the api has support for listing names
      def extend_data(os)
        os["_os_name"] = Hash[os.select { |k, v| ["name", "major", "minor"].include? k }]
        os["media_names"] = os["media"].collect{|m| m["medium"]["name"] } rescue []
        os["architecture_names"] = os["architectures"].collect{|m| m["architecture"]["name"] } rescue []
        os["ptable_names"] = os["ptables"].collect{|m| m["ptable"]["name"] } rescue []
        os["config_template_names"] = os["config_templates"].collect{|m| m["config_template"]["name"] } rescue []
        os["parameters"] = HammerCLIForeman::Parameter.get_parameters(resource_config, :operatingsystem, os)
        os
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      #FIXME: replace with apipie_options when they are added to the api docs
      option "--architecture-ids", "ARCH_IDS", "set associated architectures",
        :format => HammerCLI::Options::Normalizers::List.new
      option "--config-template-ids", "CONFIG_TPL_IDS", "set associated templates",
        :format => HammerCLI::Options::Normalizers::List.new
      option "--medium-ids", "MEDIUM_IDS", "set associated installation media",
        :format => HammerCLI::Options::Normalizers::List.new
      option "--ptable-ids", "PTABLE_IDS", "set associated partition tables",
        :format => HammerCLI::Options::Normalizers::List.new

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
      option "--architecture-ids", "ARCH_IDS", "set associated architectures",
        :format => HammerCLI::Options::Normalizers::List.new
      option "--config-template-ids", "CONFIG_TPL_IDS", "set associated templates",
        :format => HammerCLI::Options::Normalizers::List.new
      option "--medium-ids", "MEDIUM_IDS", "set associated installation media",
        :format => HammerCLI::Options::Normalizers::List.new
      option "--ptable-ids", "PTABLE_IDS", "set associated partition tables",
        :format => HammerCLI::Options::Normalizers::List.new

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

      resource ForemanApi::Resources::Parameter

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

      resource ForemanApi::Resources::Parameter

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

HammerCLI::MainCommand.subcommand 'os', "Manipulate operating system.", HammerCLIForeman::OperatingSystem

