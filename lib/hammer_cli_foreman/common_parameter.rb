require 'hammer_cli'

module HammerCLIForeman

  class CommonParameter < HammerCLIForeman::Command

    resource :common_parameters

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :name, _("Name")
        field :value, _("Value")
      end

      apipie_options
    end

    class SetCommand < HammerCLIForeman::WriteCommand

      command_name "set"
      desc _("Set a global parameter.")

      success_message_for :create, _("Created parameter [%{name}s] with value [%{value}s].")
      success_message_for :update, _("Parameter [%{name}s] updated to [%{value}s].")

      option "--name", "NAME", _("parameter name"), :required => true
      option "--value", "VALUE", _("parameter value"), :required => true

      def action
        @action ||= parameter_exist? ? :update : :create
        @action
      end

      def success_message
        success_message_for(action)
      end

      def parameter_exist?
        params = resource.call(:index)
        params = HammerCLIForeman.collection_to_common_format(params)
        params.find { |p| p["name"] == option_name }
      end

      def request_params
        params = method_options
        params['id'] = option_name
        params
      end

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :name

      success_message _("Global parameter [%{name}s] deleted.")
      failure_message _("Could not delete the global parameter [%{name}s]")

      apipie_options :without => :id
    end

    autoload_subcommands
  end
end

HammerCLI::MainCommand.subcommand 'global_parameter', _("Manipulate global parameters."), HammerCLIForeman::CommonParameter
