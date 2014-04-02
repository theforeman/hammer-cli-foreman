module HammerCLIForeman

  class Subnet < HammerCLIForeman::Command

    resource :subnets

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :network, _("Network")
        field :mask, _("Mask")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :priority, _("Priority")
        field :dns_id, _("DNS id")
        field :dns, _("DNS"), Fields::Server
        field :dns_primary, _("Primary DNS")
        field :dns_secondary, _("Secondary DNS")
        field :domain_ids, _("Domain ids"), Fields::List
        field :tftp, _("TFTP"), Fields::Server
        field :tftp_id, _("TFTP id")
        field :dhcp, _("DHCP"), Fields::Server
        field :dhcp_id, _("DHCP id")
        field :vlanid, _("vlan id")
        field :gateway, _("Gateway")
        field :from, _("From")
        field :to, _("To")
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Subnet created")
      failure_message _("Could not create the subnet")

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _("Subnet updated")
      failure_message _("Could not update the subnet")

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Subnet deleted")
      failure_message _("Could not delete the subnet")

      apipie_options
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'subnet', _("Manipulate subnets."), HammerCLIForeman::Subnet

