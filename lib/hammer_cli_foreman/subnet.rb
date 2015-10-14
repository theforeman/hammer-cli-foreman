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

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :priority, _("Priority")
        field :dns, _("DNS"), Fields::Reference, :details => :url
        field :dns_primary, _("Primary DNS")
        field :dns_secondary, _("Secondary DNS")
        field :tftp, _("TFTP"), Fields::Reference, :details => :url
        field :dhcp, _("DHCP"), Fields::Reference, :details => :url
        field :ipam, _("IPAM")
        field :vlanid, _("VLAN ID")
        field :gateway, _("Gateway")
        field :from, _("From")
        field :to, _("To")
        HammerCLIForeman::References.domains(self)
        HammerCLIForeman::References.taxonomies(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Subnet created")
      failure_message _("Could not create the subnet")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _("Subnet updated")
      failure_message _("Could not update the subnet")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Subnet deleted")
      failure_message _("Could not delete the subnet")

      build_options
    end

    autoload_subcommands
  end

end



