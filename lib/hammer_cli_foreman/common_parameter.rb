require 'hammer_cli'

module HammerCLIForeman

  class CommonParameter < HammerCLIForeman::Command

    resource :common_parameters

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :name, _("Name")
        field :value, _("Value")
        field :parameter_type, _("Type")
      end

      build_options
    end

    class SetCommand < HammerCLIForeman::Command

      command_name "set"
      desc _("Set a global parameter")

      success_message_for :create, _("Created parameter [%{name}] with value [%{value}].")
      success_message_for :update, _("Parameter [%{name}] updated to [%{value}].")

      option "--name", "NAME", _("Parameter name"), :required => true
      option "--value", "VALUE", _("Parameter value"), :required => true
      option "--hidden-value", "HIDDEN_VALUE", _("Should the value be hidden"), :format => HammerCLI::Options::Normalizers::Bool.new
      option "--parameter-type", "PARAMETER_TYPE", _("Type of the parameter"),
        :default => 'string',
        :format => HammerCLI::Options::Normalizers::Enum.new(
            ['string', 'boolean', 'integer', 'real', 'array', 'hash', 'yaml', 'json'])

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
        super.update('id' => option_name)
      end

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Global parameter [%{name}] deleted.")
      failure_message _("Could not delete the global parameter [%{name}]")

      def request_params
        super.update('id' => option_name)
      end

      build_options :without => :id
    end

    autoload_subcommands
  end
end

HammerCLI::MainCommand.subcommand 'global-parameter', _("Manipulate global parameters"), HammerCLIForeman::CommonParameter
