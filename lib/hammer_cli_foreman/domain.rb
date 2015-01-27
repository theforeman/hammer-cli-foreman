module HammerCLIForeman

  module DomainUpdateCreateCommons

    def self.included(base)
      base.option "--dns-id", "DNS_ID",  _("ID of DNS proxy to use within this domain")
      base.option "--dns", "DNS_NAME", _("Name of DNS proxy to use within this domain")
    end

    def request_params
      params = super
      params['domain']["dns_id"] = option_dns_id || dns_id(option_dns)
      params
    end

    private

    def dns_id(name)
      resolver.smart_proxy_id('option_name' => name) if name
    end

  end

  class Domain < HammerCLIForeman::Command

    resource :domains

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :fullname, _("Description")
        field :dns_id, _("DNS Id")
        HammerCLIForeman::References.subnets(self)
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.parameters(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include DomainUpdateCreateCommons

      success_message _("Domain [%{name}] created")
      failure_message _("Could not create the domain")

      option "--description", "DESC", _("Full name describing the domain"), :attribute_name => :option_fullname
      build_options :without => [:domain_parameters_attributes, :fullname, :dns_id]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include DomainUpdateCreateCommons

      success_message _("Domain [%{name}] updated")
      failure_message _("Could not update the domain")

      option "--description", "DESC", _("Full name describing the domain"), :attribute_name => :option_fullname
      build_options :without => [:domain_parameters_attributes, :fullname]
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Domain [%{name}] deleted")
      failure_message _("Could not delete the domain")

      build_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for a domain.")

      success_message_for :update, _("Domain parameter updated")
      success_message_for :create, _("New domain parameter created")
      failure_message _("Could not set domain parameter")

      def validate_options
        super
        validator.any(:option_domain_name, :option_domain_id).required
      end

      build_options
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for a domain.")

      success_message _("Domain parameter deleted")

      def validate_options
        super
        validator.any(:option_domain_name, :option_domain_id).required
      end

      build_options
    end

    autoload_subcommands
  end

end


