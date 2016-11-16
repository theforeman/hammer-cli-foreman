module HammerCLIForeman

  class SmartVariablesBriefList < HammerCLIForeman::ListCommand
    resource :smart_variables, :index
    command_name 'smart-variables'

    output do
      field :id, _("Id")

      field :variable, _('Variable')
      field :default_value, _("Default Value")
      field :parameter_type, _("Type")
    end

    def self.build_options_for(resource)
      options = {}
      options[:without] = [:host_id, :puppetclass_id, :hostgroup_id]
      options[:expand] = {}
      options[:expand][:except] = ([:hosts, :puppetclasses, :hostgroups] - [resource])
      build_options(options)
    end
  end

  class SmartVariablesList < SmartVariablesBriefList

    output do
      field :puppetclass_name, _("Puppet class")
      field :puppetclass_id, _("Class Id"), Fields::Id
    end
  end

  class SmartVariable < HammerCLIForeman::Command

    resource :smart_variables

    class ListCommand < HammerCLIForeman::ListCommand

      output SmartVariablesList.output_definition

      def extend_data(res)
        res['parameter_type'] ||= 'string'
        res
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand

      option '--name', 'NAME', _('Smart variable name'), :deprecated => _('Use --variable instead')

      output ListCommand.output_definition do
        field :description, _("Description")
        field :hidden_value?, _("Hidden Value?")

        label _("Validator") do
          field :validator_type, _("Type")
          field :validator_rule, _("Rule")
        end
        label _("Override values") do
          field :merge_overrides, _("Merge overrides"), Fields::Boolean
          field :merge_default, _("Merge default value"), Fields::Boolean
          field :avoid_duplicates, _("Avoid duplicates"), Fields::Boolean
          field :override_value_order, _("Order"), Fields::LongText
          collection :override_values, _("Values") do
              field :id, _('Id')
              field :match, _('Match')
              field :value, _('Value')
          end
        end
        HammerCLIForeman::References.timestamps(self)
      end

      def extend_data(res)
        res['parameter_type'] ||= 'string'
        res
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Smart variable [%{variable}] created")
      failure_message _("Could not create the smart variable")

      build_options :without => [:variable_type, :validator_type]

      option "--variable-type", "VARIABLE_TYPE", _("Type of the variable."),
        :format => HammerCLI::Options::Normalizers::Enum.new(
            ['string', 'boolean', 'integer', 'real', 'array', 'hash', 'yaml', 'json'])
      option "--validator-type", "VALIDATOR_TYPE", _("Type of the validator."),
        :format => HammerCLI::Options::Normalizers::Enum.new(['regexp', 'list', ''])
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _("Smart variable [%{variable}] updated")
      failure_message _("Could not update the smart variable")

      build_options :without => [:variable_type, :validator_type]

      option "--variable-type", "VARIABLE_TYPE", _("Type of the variable."),
        :format => HammerCLI::Options::Normalizers::Enum.new(
            ['string', 'boolean', 'integer', 'real', 'array', 'hash', 'yaml', 'json'])
      option "--validator-type", "VALIDATOR_TYPE", _("Type of the validator."),
        :format => HammerCLI::Options::Normalizers::Enum.new(['regexp', 'list', ''])
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      option '--name', 'NAME', _('Smart variable name'), :deprecated => _('Use --variable instead')

      success_message _("Smart variable [%{variable}] deleted")
      failure_message _("Could not delete the smart variable")

      build_options
    end


    class AddOverrideValueCommand < HammerCLIForeman::CreateCommand
      resource :override_values
      command_name 'add-override-value'

      success_message _("Override value created")
      failure_message _("Could not create the override value")

      build_options do |options|
        options.without(:smart_class_parameter_id)
        options.expand.except(:smart_class_parameters)
      end
    end

    class RemoveOverrideValueCommand < HammerCLIForeman::DeleteCommand
      resource :override_values
      command_name 'remove-override-value'

      success_message _("Override value deleted")
      failure_message _("Could not delete the override value")

      build_options do |options|
        options.without(:smart_class_parameter_id)
        options.expand.except(:smart_class_parameters)
      end
    end

    autoload_subcommands

  end
end
