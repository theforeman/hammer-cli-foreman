module HammerCLIForeman

  class SmartClassParametersBriefList < HammerCLIForeman::AssociatedResourceListCommand
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

    def self.build_options(options={})
      options[:without] ||= [:host_id, :hostgroup_id, :puppetclass_id, :environment_id]
      super(options)
    end
  end

  class SmartClassParametersList < SmartClassParametersBriefList

    output do
      from :puppetclass do
        field :name, _("Puppet class")
        field :id, _("Class Id"), Fields::Id
      end
    end
  end

  class SmartClassParameter < HammerCLIForeman::Command

    resource :smart_class_parameters

    class ListCommand < HammerCLIForeman::ListCommand

      output SmartClassParametersList.output_definition

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :description, _("Description")
        field :parameter_type, _("Type")
        field :required, _("Required")

        label _("Validator") do
          field :validator_type, _("Type")
          field :validator_rule, _("Rule")
        end
        label _("Override values") do
          field :override_value_order, _("Order"), Fields::List
          field :override_values_count, _("Count")
          collection :override_values, "Values" do
            label  _("Value") do
              field :id, _('Id')
              field :match, _('Match')
              field :value, _('Value')
            end
          end
        end
        HammerCLIForeman::References.environments(self)
        HammerCLIForeman::References.timestamps(self)
      end

      def extend_data(res)
        res['override_value_order'] = res['override_value_order'].split("\n")
        res
      end

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _("Parameter updated")
      failure_message _("Could not update the parameter")

      build_options :without => [:parameter_type, :validator_type, :override, :required]

      option "--override", "OVERRIDE", _("Override this parameter."),
        :format => HammerCLI::Options::Normalizers::Bool.new
      option "--required", "REQUIRED", _("This parameter is required."),
        :format => HammerCLI::Options::Normalizers::Bool.new
      option "--parameter-type", "PARAMETER_TYPE", _("Type of the parameter."),
        :format => HammerCLI::Options::Normalizers::Enum.new(
            ['string', 'boolean', 'integer', 'real', 'array', 'hash', 'yaml', 'json'])
      option "--validator-type", "VALIDATOR_TYPE", _("Type of the validator."),
        :format => HammerCLI::Options::Normalizers::Enum.new(['regexp', 'list', ''])
    end


    autoload_subcommands

  end

  HammerCLI::MainCommand.subcommand 'sc-param', _("Manipulate smart class parameters."), HammerCLIForeman::SmartClassParameter

end
