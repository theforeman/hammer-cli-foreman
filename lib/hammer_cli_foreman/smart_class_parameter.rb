require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'


module HammerCLIForeman

  class SmartClassParametersBriefList < HammerCLIForeman::ListCommand
    resource ForemanApi::Resources::SmartClassParameter, "index"
    command_name 'sc_params'

    output do
      field :id, "Id"

      field :parameter, "Parameter"
      field :default_value, "Default Value"
      field :override, "Override"
    end

    def retrieve_data
      res = super
      # FIXME: API returns doubled records, probably just if filtered by puppetclasses
      # it seems group by environment is missing
      # having the uniq to fix that
      HammerCLI::Output::RecordCollection.new(res.uniq, :meta => res.meta)
    end
  end

  class SmartClassParametersList < SmartClassParametersBriefList

    output do
      from :puppetclass do
        field :name, "Puppet class"
        field :id, "Class Id", Fields::Id
      end
    end
  end

  class SmartClassParameter < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::SmartClassParameter

    class ListCommand < HammerCLIForeman::SmartClassParametersList
      command_name 'list'
      apipie_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :description, "Description"
        field :parameter_type, "Type"
        field :required, "Required"
        field :_environments, "Environments", Fields::List
        field :_environment_ids, "Environment Ids", Fields::List
        label "Validator" do
          field :validator_type, "Type"
          field :validator_rule, "Rule"
        end
        label "Override values" do
          field :override_value_order, "Order", Fields::List
          field :override_values_count, "Count"
          collection :override_values, "Values" do
            label  "Value" do
              field :id, 'Id'
              field :match, 'Match'
              field :value, 'Value'
            end
          end
        end
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
      end

      def extend_data(res)
        res['override_value_order'] = res['override_value_order'].split("\n")
        res['_environments'] = res['environments'].map { |e| e['environment']['name']}
        res['_environment_ids'] = res['environments'].map { |e| e['environment']['id']}
        res
      end

      apipie_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Parameter updated"
      failure_message "Could not update the parameter"

      apipie_options :without => [:parameter_type, :validator_type, :id, :override, :required]

      option "--override", "OVERRIDE", "Override this parameter.",
        :format => HammerCLI::Options::Normalizers::Bool.new
      option "--required", "REQUIRED", "This parameter is required.",
        :format => HammerCLI::Options::Normalizers::Bool.new
      option "--parameter-type", "PARAMETER_TYPE", "Type of the parameter.",
        :format => HammerCLI::Options::Normalizers::Enum.new(
            ['string', 'boolean', 'integer', 'real', 'array', 'hash', 'yaml', 'json'])
      option "--validator-type", "VALIDATOR_TYPE", "Type of the validator.",
        :format => HammerCLI::Options::Normalizers::Enum.new(['regexp', 'list', ''])
    end


    autoload_subcommands

  end

  HammerCLI::MainCommand.subcommand 'sc_param', "Manipulate smart class parameters.", HammerCLIForeman::SmartClassParameter

end
