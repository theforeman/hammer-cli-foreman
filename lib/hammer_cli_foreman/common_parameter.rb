require 'hammer_cli'
require 'foreman_api'

module HammerCLIForeman

  class CommonParameter < HammerCLI::AbstractCommand


    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::CommonParameter, "index"

      output do
        field :name, "Name"
        field :value, "Value"
      end

      apipie_options
    end

    class SetCommand < HammerCLIForeman::WriteCommand

      command_name "set"
      desc "Set a global parameter."

      success_message_for :create, "Created parameter [%{name}s] with value [%{value}s]."
      success_message_for :update, "Parameter [%{name}s] updated to [%{value}s]."

      resource ForemanApi::Resources::CommonParameter

      option "--name", "NAME", "parameter name", :required => true
      option "--value", "VALUE", "parameter value", :required => true

      def action
        @action ||= parameter_exist? ? :update : :create
        @action
      end

      def success_message
        success_message_for(action)
      end

      def parameter_exist?
        params = resource.call(:index)[0]
        params.find { |p| p["common_parameter"]["name"] == name }
      end

      def request_params
        params = method_options
        params['id'] = name
        params
      end

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :name

      success_message "Global parameter [%{name}s] deleted."
      failure_message "Could not delete the global parameter [%{name}s]"
      resource ForemanApi::Resources::CommonParameter, "destroy"

      apipie_options :without => :id
    end

    autoload_subcommands
  end
end

HammerCLI::MainCommand.subcommand 'global_parameter', "Manipulate global parameters.", HammerCLIForeman::CommonParameter
