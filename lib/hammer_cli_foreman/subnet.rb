module HammerCLIForeman

   module SubnetUpdateCreateCommons

    def self.included(base)
      base.option "--dns", "DNS_NAME", _("DNS Proxy to use within this subnet")
      base.option "--dhcp", "DHCP_NAME", _("DHCP Proxy to use within this subnet")
      base.option "--tftp", "TFTP_NAME", _("TFTP Proxy to use within this subnet")
    end

    def request_params
      params = super
      params['subnet']["dns_id"] ||= proxy_feature_id(option_dns) if option_dns
      params['subnet']["dhcp_id"] ||= proxy_feature_id(option_dhcp) if option_dhcp
      params['subnet']["tftp_id"] ||= proxy_feature_id(option_tftp) if option_tftp
      params
    end

    private

    def proxy_feature_id(name)
      resolver.smart_proxy_id('option_name' => name) if name
    end
  end

  class Subnet < HammerCLIForeman::Command

    resource :subnets

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :network, _("Network Addr")
        field :cidr, _("Network Prefix")
        field :mask, _("Network Mask")
        field :vlanid, _("VLAN ID")
        field :boot_mode, _("Boot Mode")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :description, _("Description"), Fields::LongText, :hide_blank => true
        field :network_type, _("Protocol")
        field :priority, _("Priority")
        field :network, _("Network Addr")
        field :cidr, _("Network Prefix")
        field :mask, _("Network Mask")
        field :gateway, _("Gateway Addr")
        field :dns_primary, _("Primary DNS")
        field :dns_secondary, _("Secondary DNS")
        label _("Smart Proxies") do
          field :dns, _("DNS"), Fields::Reference, :details => [{ :structured_label => _('Url'), :key => :url }]
          field :tftp, _("TFTP"), Fields::Reference, :details => [{ :structured_label => _('Url'), :key => :url }]
          field :dhcp, _("DHCP"), Fields::Reference, :details => [{ :structured_label => _('Url'), :key => :url }]
        end
        field :ipam, _("IPAM")
        field :from, _("Start of IP Range")
        field :to, _("End of IP Range")
        field :vlanid, _("VLAN ID")
        field :mtu, _("MTU")
        field :boot_mode, _("Boot Mode")
        HammerCLIForeman::References.domains(self)
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.parameters(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include SubnetUpdateCreateCommons

      success_message _("Subnet created.")
      failure_message _("Could not create the subnet")

      build_options :without => [:subnet_parameters_attributes]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include SubnetUpdateCreateCommons

      success_message _("Subnet updated.")
      failure_message _("Could not update the subnet")

      build_options :without => [:subnet_parameters_attributes]
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Subnet deleted.")
      failure_message _("Could not delete the subnet")

      build_options :without => [:subnet_parameters_attributes]
    end

    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for a subnet")

      success_message_for :update, _("Subnet parameter updated")
      success_message_for :create, _("New subnet parameter created")
      failure_message _("Could not set subnet parameter")

      def validate_options
        super
        validator.any(:option_subnet_name, :option_subnet_id).required
      end

      build_options
    end

    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for a subnet")

      success_message _("Subnet parameter deleted.")

      def validate_options
        super
        validator.any(:option_subnet_name, :option_subnet_id).required
      end

      build_options
    end

    autoload_subcommands
  end

end
