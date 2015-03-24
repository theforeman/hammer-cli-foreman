require 'hammer_cli_foreman/smart_class_parameter'
require 'hammer_cli_foreman/smart_variable'

module HammerCLIForeman

  class PuppetClass < HammerCLIForeman::Command

    resource :puppetclasses

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      def send_request
        self.class.unhash_classes(super)
      end

      def self.unhash_classes(classes)
        clss = classes.first.inject([]) { |list, (pp_module, pp_module_classes)| list + pp_module_classes }

        HammerCLI::Output::RecordCollection.new(clss, :meta => classes.meta)

      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        collection :smart_variables, _("Smart variables") do
          field :key, _("Parameter")
          field :default_value, _("Default value")
        end
        collection :smart_class_parameters, _("Smart class parameters"), :numbered => false do
          custom_field Fields::Reference, :name_key => :parameter
        end
        HammerCLIForeman::References.hostgroups(self)
        HammerCLIForeman::References.environments(self)
        HammerCLIForeman::References.parameters(self)
      end

      build_options
    end


    class SCParamsCommand < HammerCLIForeman::SmartClassParametersBriefList
      build_options_for :puppetclasses

      def validate_options
        super
        validator.any(:option_puppetclass_name, :option_puppetclass_id).required
      end
    end

    class SmartVariablesCommand < HammerCLIForeman::SmartVariablesBriefList
      build_options_for :puppetclasses

      def validate_options
        super
        validator.any(:option_puppetclass_name, :option_puppetclass_id).required
      end
    end


    autoload_subcommands
  end

end



