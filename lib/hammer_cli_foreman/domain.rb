require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/parameter'

module HammerCLIForeman

  class Domain < HammerCLI::AbstractCommand
    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::Domain, "index"

      heading "Domain list"
      output do
        from "domain" do
          field :id, "Id"
          field :name, "Name"
          field :created_at, "Created at", &HammerCLIForeman::Formatters.method(:date_formatter)
          field :updated_at, "Updated at", &HammerCLIForeman::Formatters.method(:date_formatter)
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      resource ForemanApi::Resources::Domain, "show"

      def retrieve_data
        domain = super
        domain["parameters"] = HammerCLIForeman::Parameter.get_parameters resource_config, domain
        domain
      end

      heading "Domain info"
      output ListCommand.output_definition do
        from "domain" do
          field :fullname, "Full Name"
          field :dns_id, "DNS Id"
        end
        field :parameters, "Parameters", &HammerCLIForeman::Formatters.method(:parameters)
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Domain created"
      failure_message "Could not create the domain"
      resource ForemanApi::Resources::Domain, "create"

      apipie_options :without => ['domain_parameters_attributes']
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Domain updated"
      failure_message "Could not update the domain"
      resource ForemanApi::Resources::Domain, "update"

      apipie_options :without => ['domain_parameters_attributes', 'name', 'id']
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Domain deleted"
      failure_message "Could not delete the domain"
      resource ForemanApi::Resources::Domain, "destroy"

      apipie_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      option "--domain-name", "DOMAIN_NAME", "name of the domain the parameter is being set for"
      option "--domain-id", "DOMAIN_ID", "id of the domain the parameter is being set for"

      success_message_for :update, "Domain parameter updated"
      success_message_for :create, "New domain parameter created"
      failure_message "Could not set domain parameter"

      def validate_options
        super
        validator.any(:domain_name, :domain_id).required
      end

      def base_action_params
        {
          "domain_id" => domain_id || domain_name
        }
      end
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand

      option "--domain-name", "DOMAIN_NAME", "name of the domain the parameter is being deleted for"
      option "--domain-id", "DOMAIN_ID", "id of the domain the parameter is being deleted for"

      success_message "Domain parameter deleted"

      def validate_options
        super
        validator.any(:domain_name, :domain_id).required
      end

      def base_action_params
        {
          "domain_id" => domain_id || domain_name
        }
      end
    end

    subcommand "list", "List domains.", HammerCLIForeman::Domain::ListCommand
    subcommand "info", "Detailed info about a domain.", HammerCLIForeman::Domain::InfoCommand
    subcommand "create", "Create a new domain.", HammerCLIForeman::Domain::CreateCommand
    subcommand "update", "Update a domain.", HammerCLIForeman::Domain::UpdateCommand
    subcommand "delete", "Delete a domain.", HammerCLIForeman::Domain::DeleteCommand
    subcommand "set_parameter", "Create or update parameter for a domain.", HammerCLIForeman::Domain::SetParameterCommand
    subcommand "delete_parameter", "Delete parameter for a domain.", HammerCLIForeman::Domain::DeleteParameterCommand
  end

end

HammerCLI::MainCommand.subcommand 'domain', "Manipulate Foreman's domains.", HammerCLIForeman::Domain

