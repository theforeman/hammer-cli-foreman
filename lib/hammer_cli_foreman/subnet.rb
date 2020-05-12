module HammerCLIForeman

  module SubnetUpdateCreateCommons
    def request_params
      params = super
      if option_prefix || option_mask
        if params['subnet']['network_type'] == 'IPv6'
          params['subnet']['cidr'] = (option_prefix || network_prefix).to_s
        else
          params['subnet']['mask'] = option_mask || network_mask
        end
      end
      params
    end

    private

    def network_mask
      require 'ipaddr'
      IPAddr.new('255.255.255.255').mask(option_prefix).to_s
    end

    def network_prefix
      require 'ipaddr'
      IPAddr.new(option_mask).to_i.to_s(2).count('1')
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
        field :gateway, _("Gateway Address")
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
          field :dns, _("DNS"), Fields::Reference, :details => :url
          field :tftp, _("TFTP"), Fields::Reference, :details => :url
          field :dhcp, _("DHCP"), Fields::Reference, :details => :url
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

      validate_options do
        any(:option_mask, :option_prefix).required
      end

      build_options :without => [:subnet_parameters_attributes, :cidr]

      extend_with(HammerCLIForeman::CommandExtensions::Subnet.new)
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include SubnetUpdateCreateCommons

      success_message _("Subnet updated.")
      failure_message _("Could not update the subnet")

      build_options :without => [:subnet_parameters_attributes, :cidr]

      extend_with(HammerCLIForeman::CommandExtensions::Subnet.new)
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
