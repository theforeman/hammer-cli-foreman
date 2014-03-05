module HammerCLIForeman

  class Subnet < HammerCLI::AbstractCommand
    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::Subnet, "index"

      output do
        field :id, "Id"
        field :name, "Name"
        field :network, "Network"
        field :mask, "Mask"
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      resource ForemanApi::Resources::Subnet, "show"

      output ListCommand.output_definition do
        field :priority, "Priority"
        field :dns_id, "DNS id"
        field :dns, "DNS", Fields::Server
        field :dns_primary, "Primary DNS"
        field :dns_secondary, "Secondary DNS"
        field :domain_ids, "Domain ids", Fields::List
        field :tftp, "TFTP", Fields::Server
        field :tftp_id, "TFTP id"
        field :dhcp, "DHCP", Fields::Server
        field :dhcp_id, "DHCP id"
        field :vlanid, "vlan id"
        field :gateway, "Gateway"
        field :from, "From"
        field :to, "To"
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Subnet created"
      failure_message "Could not create the subnet"
      resource ForemanApi::Resources::Subnet, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Subnet updated"
      failure_message "Could not update the subnet"
      resource ForemanApi::Resources::Subnet, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Subnet deleted"
      failure_message "Could not delete the subnet"
      resource ForemanApi::Resources::Subnet, "destroy"

      apipie_options
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'subnet', "Manipulate subnets.", HammerCLIForeman::Subnet

