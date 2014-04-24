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

    def retrieve_data
      res = super
      # FIXME: API returns doubled records, probably just if filtered by puppetclasses
      # it seems group by environment is missing
      # having the uniq to fix that
      HammerCLI::Output::RecordCollection.new(res.uniq, :meta => res.meta)
    end

    build_options :without => [:host_id, :hostgroup_id, :puppetclass_id, :environment_id]
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

    class ListCommand < HammerCLIForeman::SmartClassParametersList
      command_name 'list'
      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :description, _("Description")
        field :parameter_type, _("Type")
        field :required, _("Required")
        field :_environments, _("Environments"), Fields::List
        field :_environment_ids, _("Environment Ids"), Fields::List
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
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      def extend_data(res)
        res['override_value_order'] = res['override_value_order'].split("\n")
        res['_environments'] = res['environments'].map { |e| e['name']}
        res['_environment_ids'] = res['environments'].map { |e| e['id']}
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
