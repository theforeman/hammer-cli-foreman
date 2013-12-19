module HammerCLIForeman

  class OperatingSystem < HammerCLIForeman::Command

    resource :operatingsystems

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :_os_name, _("Name"), Fields::OSName
        field :release_name, _("Release name")
        field :family, _("Family")
      end

      def extend_data(os)
        os["_os_name"] = Hash[os.select { |k, v| ["name", "major", "minor"].include? k }]
        os
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      identifiers :id

      output ListCommand.output_definition do
        field :media_names, _("Installation media"), Fields::List
        field :architecture_names, _("Architectures"), Fields::List
        field :ptable_names, _("Partition tables"), Fields::List
        field :config_template_names, _("Config templates"), Fields::List
        collection :parameters, _("Parameters") do
          field nil, nil, Fields::KeyValue
        end
      end

      #FIXME: remove custom retrieve_data after the api has support for listing names
      def extend_data(os)
        os["_os_name"] = Hash[os.select { |k, v| ["name", "major", "minor"].include? k }]
        os["media_names"] = os["media"].collect{|m| m["name"] } rescue []
        os["architecture_names"] = os["architectures"].collect{|m| m["name"] } rescue []
        os["ptable_names"] = os["ptables"].collect{|m| m["name"] } rescue []
        os["config_template_names"] = os["config_templates"].collect{|m| m["name"] } rescue []
        os["parameters"] = HammerCLIForeman::Parameter.get_parameters(resource_config, :operatingsystem, os)
        os
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      #FIXME: replace with apipie_options when they are added to the api docs
      option "--architecture-ids", "ARCH_IDS", _("set associated architectures"),
        :format => HammerCLI::Options::Normalizers::List.new
      option "--config-template-ids", "CONFIG_TPL_IDS", _("set associated templates"),
        :format => HammerCLI::Options::Normalizers::List.new
      option "--medium-ids", "MEDIUM_IDS", _("set associated installation media"),
        :format => HammerCLI::Options::Normalizers::List.new
      option "--ptable-ids", "PTABLE_IDS", _("set associated partition tables"),
        :format => HammerCLI::Options::Normalizers::List.new

      success_message _("Operating system created")
      failure_message _("Could not create the operating system")

      def request_params
        params = method_options
        params["operatingsystem"]["architecture_ids"] = option_architecture_ids if option_architecture_ids
        params["operatingsystem"]["config_template_ids"] = option_config_template_ids if option_config_template_ids
        params["operatingsystem"]["medium_ids"] = option_medium_ids if option_medium_ids
        params["operatingsystem"]["ptable_ids"] = option_ptable_ids if option_ptable_ids
        params
      end

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      #FIXME: replace with apipie_options when they are added to the api docs
      option "--architecture-ids", "ARCH_IDS", _("set associated architectures"),
        :format => HammerCLI::Options::Normalizers::List.new
      option "--config-template-ids", "CONFIG_TPL_IDS", _("set associated templates"),
        :format => HammerCLI::Options::Normalizers::List.new
      option "--medium-ids", "MEDIUM_IDS", _("set associated installation media"),
        :format => HammerCLI::Options::Normalizers::List.new
      option "--ptable-ids", "PTABLE_IDS", _("set associated partition tables"),
        :format => HammerCLI::Options::Normalizers::List.new

      identifiers :id

      success_message _("Operating system updated")
      failure_message _("Could not update the operating system")

      def request_params
        params = method_options
        params["operatingsystem"]["architecture_ids"] = option_architecture_ids if option_architecture_ids
        params["operatingsystem"]["config_template_ids"] = option_config_template_ids if option_config_template_ids
        params["operatingsystem"]["medium_ids"] = option_medium_ids if option_medium_ids
        params["operatingsystem"]["ptable_ids"] = option_ptable_ids if option_ptable_ids
        params
      end

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id

      success_message _("Operating system deleted")
      failure_message _("Could not delete the operating system")

      apipie_options
    end

    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      resource :parameters

      desc _("Create or update parameter for an operating system.")

      #FIXME: add option --os-label when api supports it
      option "--os-id", "OS_ID", _("id of the operating system the parameter is being set for")

      success_message_for :update, _("Operating system parameter updated")
      success_message_for :create, _("New operating system parameter created")
      failure_message _("Could not set operating system parameter")

      def validate_options
        super
        validator.any(:option_os_id).required
      end

      def base_action_params
        {
          "operatingsystem_id" => option_os_id
        }
      end
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand

      resource :parameters

      desc _("Delete parameter for an operating system.")

      #FIXME: add option --os-label when api supports it
      option "--os-id", "OS_ID", _("id of the operating system the parameter is being deleted for")
      success_message _("operating system parameter deleted")

      def validate_options
        super
        validator.any(:option_os_id).required
      end

      def base_action_params
        {
          "operatingsystem_id" => option_os_id
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

