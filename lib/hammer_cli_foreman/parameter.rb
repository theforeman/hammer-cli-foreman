require 'hammer_cli/messages'

module HammerCLIForeman

  module Parameter

    class AbstractParameterCommand < HammerCLIForeman::Command

      def self.parameter_resource
        HammerCLIForeman.foreman_resource!(:parameters)
      end

      def parameter_resource
        self.class.parameter_resource
      end

      def get_identifier
        @identifier ||= get_resource_id(resource, :scoped => true)
        @identifier
      end

      def get_parameter_identifier
        if @parameter_identifier.nil?
          opts = all_options
          opts[HammerCLI.option_accessor_name("#{resource.singular_name}_id")] ||= get_identifier
          @parameter_identifier = resolver.send("#{parameter_resource.singular_name}_id", opts)
        end
        @parameter_identifier
      end

      def base_action_params
        {
          "#{resource.singular_name}_id" => get_identifier
        }
      end

      def self.create_option_builder
        builder = super
        builder.builders = [
          DependentSearchablesOptionBuilder.new(resource, searchables)
        ]
        builder
      end

    end


    class SetCommand < AbstractParameterCommand
      option "--name", "NAME", _("parameter name"), :required => true
      option "--value", "VALUE", _("parameter value"), :required => true

      def self.command_name(name=nil)
        (super(name) || "set-parameter").gsub('_', '-')
      end

      def execute
        if parameter_exist?
          response = update_parameter
          print_message(success_message_for(:update), response) if success_message_for(:update)
        else
          response = create_parameter
          print_message(success_message_for(:create), response) if success_message_for(:create)
        end
        HammerCLI::EX_OK
      end

      def parameter_exist?
        get_parameter_identifier rescue false
      end

      def update_parameter
        params = {
          "id" => get_parameter_identifier,
          "parameter" => {
            "value" => option_value
          }
        }.merge(base_action_params)
        HammerCLIForeman.record_to_common_format(parameter_resource.call(:update, params))
      end

      def create_parameter
        params = {
          "parameter" => {
            "name" => option_name,
            "value" => option_value
          }
        }.merge(base_action_params)

        HammerCLIForeman.record_to_common_format(parameter_resource.call(:create, params))
      end

    end


    class DeleteCommand < AbstractParameterCommand
      option "--name", "NAME", _("parameter name"), :required => true

      def self.command_name(name=nil)
        (super(name) || "delete-parameter").gsub('_', '-')
      end

      def execute
        params = {
          "id" => get_parameter_identifier
        }.merge(base_action_params)

        response = HammerCLIForeman.record_to_common_format(parameter_resource.call(:destroy, params))
        print_message(success_message, response) if success_message
        HammerCLI::EX_OK
      end

    end

  end
end


