require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class Subnet < HammerCLI::AbstractCommand
    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::Subnet, "index"

      heading "Subnet list"
      output do
        from "subnet" do
          field :id, "Id"
          field :name, "Name"
          field :network, "Network"
          field :mask, "Mask"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      def self.server_formatter server
        server["name"] +" ("+ server["url"] +")" if server
      end

      resource ForemanApi::Resources::Subnet, "show"

      heading "Subnet info"
      output ListCommand.output_definition do
        from "subnet" do
          field :priority, "Priority"
          field :dns, "DNS", &method(:server_formatter)
          field :dns_primary, "Primary DNS"
          field :dns_secondary, "Secondary DNS"
          field :domain_ids, "Domain ids"
          field :tftp, "TFTP", &method(:server_formatter)
          field :tftp_id, "TFTP id"
          field :dhcp, "DHCP", &method(:server_formatter)
          field :dhcp_id, "DHCP id"
          field :vlanid, "vlan id"
          field :gateway, "Gateway"
          field :from, "From"
          field :to, "To"
        end
      end

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

    subcommand "list", "List architectures.", HammerCLIForeman::Subnet::ListCommand
    subcommand "info", "Detailed info about an architecture.", HammerCLIForeman::Subnet::InfoCommand
    subcommand "create", "Create new architecture.", HammerCLIForeman::Subnet::CreateCommand
    subcommand "update", "Update an architecture.", HammerCLIForeman::Subnet::UpdateCommand
    subcommand "delete", "Delete an architecture.", HammerCLIForeman::Subnet::DeleteCommand
  end

end

HammerCLI::MainCommand.subcommand 'subnet', "Manipulate Foreman's subnets.", HammerCLIForeman::Subnet

