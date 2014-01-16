require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/parameter'

module HammerCLIForeman

  class Domain < HammerCLI::AbstractCommand
    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::Domain, "index"

      output do
        field :id, "Id"
        field :name, "Name"
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      resource ForemanApi::Resources::Domain, "show"

      output ListCommand.output_definition do
        field :fullname, "Description"
        field :dns_id, "DNS Id"
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
        collection :parameters, "Parameters" do
          field nil, nil, Fields::KeyValue
        end
      end

      def extend_data(record)
        record["parameters"] = HammerCLIForeman::Parameter.get_parameters(resource_config, :domain, record)
        record
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Domain [%{name}s] created"
      failure_message "Could not create the domain"
      resource ForemanApi::Resources::Domain, "create"

      apipie_options :without => [:domain_parameters_attributes, :fullname]
      option "--description", "DESC", "Full name describing the domain", :attribute_name => :option_fullname
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Domain [%{name}s] updated"
      failure_message "Could not update the domain"
      resource ForemanApi::Resources::Domain, "update"

      apipie_options :without => [:domain_parameters_attributes, :name, :id, :fullname]
      option "--description", "DESC", "Full name describing the domain", :attribute_name => :option_fullname
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Domain [%{name}s] deleted"
      failure_message "Could not delete the domain"
      resource ForemanApi::Resources::Domain, "destroy"

      apipie_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      resource ForemanApi::Resources::Parameter

      desc "Create or update parameter for a domain."

      option "--domain-name", "DOMAIN_NAME", "name of the domain the parameter is being set for"
      option "--domain-id", "DOMAIN_ID", "id of the domain the parameter is being set for"

      success_message_for :update, "Domain parameter updated"
      success_message_for :create, "New domain parameter created"
      failure_message "Could not set domain parameter"

      def validate_options
        super
        validator.any(:option_domain_name, :option_domain_id).required
      end

      def base_action_params
        {
          "domain_id" => option_domain_id || option_domain_name
        }
      end
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand

      resource ForemanApi::Resources::Parameter

      desc "Delete parameter for a domain."

      option "--domain-name", "DOMAIN_NAME", "name of the domain the parameter is being deleted for"
      option "--domain-id", "DOMAIN_ID", "id of the domain the parameter is being deleted for"

      success_message "Domain parameter deleted"

      def validate_options
        super
        validator.any(:option_domain_name, :option_domain_id).required
      end

      def base_action_params
        {
          "domain_id" => option_domain_id || option_domain_name
        }
      end
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'domain', "Manipulate domains.", HammerCLIForeman::Domain

