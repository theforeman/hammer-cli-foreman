module HammerCLIForeman

  class SmartClassParametersBriefList < HammerCLIForeman::ListCommand
    resource :smart_class_parameters, :index
    command_name 'sc-params'

    output do
      field :id, _("Id")

      field :parameter, _("Parameter")
      field :default_value, _("Default Value")
      field :override, _("Override")
    end

    def send_request
      res = super
      # FIXME: API returns doubled records, probably just if filtered by puppetclasses
      # it seems group by environment is missing
      # having the uniq to fix that
      HammerCLI::Output::RecordCollection.new(res.uniq, :meta => res.meta)
    end

    def self.build_options_for(resource)
      options = {}
      options[:without] = [:host_id, :puppetclass_id, :environment_id, :hostgroup_id]
      options[:expand] = {}
      options[:expand][:except] = ([:hosts, :puppetclasses, :environments, :hostgroups] - [resource])
      build_options(options)
    end
  end

  class SmartClassParametersList < SmartClassParametersBriefList

    output do
      field :puppetclass_name, _("Puppet class")
      field :puppetclass_id, _("Class Id"), Fields::Id
    end
  end

  class SmartClassParameter < HammerCLIForeman::Command

    resource :smart_class_parameters

    class ListCommand < HammerCLIForeman::ListCommand

      output SmartClassParametersList.output_definition

      def extend_data(res)
        res['parameter_type'] ||= 'string'
        res
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :description, _("Description")
        field :parameter_type, _("Type")
        field :hidden_value?, _("Hidden Value?")
        field :use_puppet_default, _("Use puppet default"), Fields::Boolean
        field :required, _("Required")

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
              field :use_puppet_default, _('Use puppet default'), Fields::Boolean
          end
        end
        HammerCLIForeman::References.environments(self)
        HammerCLIForeman::References.timestamps(self)
      end

      def extend_data(res)
        res['parameter_type'] ||= 'string'
        res['use_puppet_default'] ||= false
        res
      end

      build_options do |options|
        options.expand.including(:puppetclasses)
      end

      validate_options do
        if option(:option_name).exist?
          any(:option_puppetclass_name, :option_puppetclass_id).required
        end
      end
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _("Parameter updated")
      failure_message _("Could not update the parameter")

      build_options do |options|
        options.expand.including(:puppetclasses)
        options.without(:parameter_type, :validator_type, :override, :required)
      end

      option "--override", "OVERRIDE", _("Override this parameter."),
        :format => HammerCLI::Options::Normalizers::Bool.new
      option "--required", "REQUIRED", _("This parameter is required."),
        :format => HammerCLI::Options::Normalizers::Bool.new
      option "--parameter-type", "PARAMETER_TYPE", _("Type of the parameter."),
        :format => HammerCLI::Options::Normalizers::Enum.new(
            ['string', 'boolean', 'integer', 'real', 'array', 'hash', 'yaml', 'json'])
      option "--validator-type", "VALIDATOR_TYPE", _("Type of the validator."),
        :format => HammerCLI::Options::Normalizers::Enum.new(['regexp', 'list', ''])

      validate_options do
        if option(:option_name).exist?
          any(:option_puppetclass_name, :option_puppetclass_id).required
        end
      end
    end

    class AddOverrideValueCommand < HammerCLIForeman::CreateCommand
      resource :override_values
      command_name 'add-override-value'

      success_message _("Override value created")
      failure_message _("Could not create the override value")

      build_options do |options|
        options.without(:smart_variable_id)
        options.expand.except(:smart_variables)
        options.expand.including(:puppetclasses)
      end

      validate_options do
        if option(:option_use_puppet_default).value
          option(:option_value).rejected(:msg => _('Cannot use --value when --use-puppet-default is true'))
        end

        if option(:option_smart_class_parameter_name).exist?
          any(:option_puppetclass_name, :option_puppetclass_id).required
        end
      end
    end

    class RemoveOverrideValueCommand < HammerCLIForeman::DeleteCommand
      resource :override_values
      command_name 'remove-override-value'

      success_message _("Override value deleted")
      failure_message _("Could not delete the override value")

      build_options do |options|
        options.without(:smart_variable_id)
        options.expand.except(:smart_variables)
        options.expand.including(:puppetclasses)
      end

      validate_options do
        if option(:option_smart_class_parameter_name).exist?
          any(:option_puppetclass_name, :option_puppetclass_id).required
        end
      end
    end

    autoload_subcommands

  end



end
