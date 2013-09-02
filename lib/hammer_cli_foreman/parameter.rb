require 'hammer_cli'
require 'hammer_cli/messages'
require 'foreman_api'

module HammerCLIForeman

  module Parameter

    def self.get_parameters(resource_config, resource)
      resource_type = resource.keys.first
      resource = resource[resource_type]
      params = {
        resource_type.to_s+"_id" => resource["id"] || resource["name"]
      }

      ForemanApi::Resources::Parameter.new(resource_config).index(params)[0]
    end

    class SetCommand < HammerCLI::Apipie::Command

      include HammerCLI::Messages
      resource ForemanApi::Resources::Parameter

      option "--name", "NAME", "parameter name", :required => true
      option "--value", "VALUE", "parameter value", :required => true

      def self.command_name(name=nil)
        super(name) || "set_parameter"
      end

      def execute
        if parameter_exist?
          update_parameter
          output.print_message success_message_for :update if  success_message_for :update
        else
          create_parameter
          output.print_message success_message_for :create if  success_message_for :create
        end
        0
      end

      def base_action_params
        {}
      end

      def parameter_exist?
        params = resource.index(base_action_params)[0]
        params.find { |p| p["parameter"]["name"] == name }
      end

      def update_parameter
        params = {
          "id" => name,
          "parameter" => {
            "value" => value
          }
        }.merge base_action_params

        resource.update(params)
      end

      def create_parameter
        params = {
          "parameter" => {
            "name" => name,
            "value" => value
          }
        }.merge base_action_params

        resource.create(params)
      end

    end


    class DeleteCommand < HammerCLI::Apipie::Command

      include HammerCLI::Messages
      resource ForemanApi::Resources::Parameter

      option "--name", "NAME", "parameter name", :required => true

      def self.command_name(name=nil)
        super(name) || "delete_parameter"
      end

      def execute
        params = {
          "id" => name
        }.merge base_action_params

        resource.destroy(params)
        output.print_message success_message if success_message
        0
      end

      def base_action_params
        {}
      end

    end

  end
end


