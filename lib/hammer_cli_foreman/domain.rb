module HammerCLIForeman

  class Domain < HammerCLIForeman::Command

    resource :domains

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :fullname, _("Description")
        field :dns_id, _("DNS Id")
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
        collection :parameters, _("Parameters") do
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

      success_message _("Domain [%{name}s] created")
      failure_message _("Could not create the domain")

      apipie_options :without => [:domain_parameters_attributes, :fullname]
      option "--description", "DESC", _("Full name describing the domain"), :attribute_name => :option_fullname
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _("Domain [%{name}s] updated")
      failure_message _("Could not update the domain")

      apipie_options :without => [:domain_parameters_attributes, :name, :id, :fullname]
      option "--description", "DESC", _("Full name describing the domain"), :attribute_name => :option_fullname
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Domain [%{name}s] deleted")
      failure_message _("Could not delete the domain")

      apipie_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      resource :parameters

      desc _("Create or update parameter for a domain.")

      option "--domain-name", "DOMAIN_NAME", _("name of the domain the parameter is being set for")
      option "--domain-id", "DOMAIN_ID", _("id of the domain the parameter is being set for")

      success_message_for :update, _("Domain parameter updated")
      success_message_for :create, _("New domain parameter created")
      failure_message _("Could not set domain parameter")

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

      resource :parameters

      desc _("Delete parameter for a domain.")

      option "--domain-name", "DOMAIN_NAME", _("name of the domain the parameter is being deleted for")
      option "--domain-id", "DOMAIN_ID", _("id of the domain the parameter is being deleted for")

      success_message _("Domain parameter deleted")

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

HammerCLI::MainCommand.subcommand 'domain', _("Manipulate domains."), HammerCLIForeman::Domain

