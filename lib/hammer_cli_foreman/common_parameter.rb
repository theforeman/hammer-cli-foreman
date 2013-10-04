require 'hammer_cli'
require 'foreman_api'

module HammerCLIForeman

  class CommonParameter < HammerCLI::AbstractCommand


    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::CommonParameter, "index"

      output do
        from "common_parameter" do
          field :name, "Name"
          field :value, "Value"
        end
      end

      apipie_options
    end

    class SetCommand < HammerCLI::Apipie::WriteCommand

      command_name "set"
      desc "Set a global parameter."

      resource ForemanApi::Resources::CommonParameter

      option "--name", "NAME", "parameter name", :required => true
      option "--value", "VALUE", "parameter value", :required => true

      def execute
        if parameter_exist?
          self.class.action :update
        else
          self.class.action :create
        end
        super
      end

      def print_message
        if self.class.action == :create
          msg = "Global parameter created"
        else
          msg = "Global parameter updated"
        end
        print_message msg
      end

      def parameter_exist?
        params = resource.index(resource_config)[0]
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

      success_message "Global parameter deleted"
      failure_message "Could not delete the global parameter"
      resource ForemanApi::Resources::CommonParameter, "destroy"

      apipie_options :without => :id
    end

    autoload_subcommands
  end
end

HammerCLI::MainCommand.subcommand 'global_parameter', "Manipulate Foreman's global parameters.", HammerCLIForeman::CommonParameter
