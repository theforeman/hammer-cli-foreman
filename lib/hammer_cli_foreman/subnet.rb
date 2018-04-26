module HammerCLIForeman

  class Subnet < HammerCLIForeman::Command

    resource :subnets

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :network, _("Network")
        field :mask, _("Mask")
        field :vlanid, _("VLAN ID")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :description, _("Description"), Fields::LongText, :hide_blank => true
        field :priority, _("Priority")
        field :dns, _("DNS"), Fields::Reference, :details => :url
        field :dns_primary, _("Primary DNS")
        field :dns_secondary, _("Secondary DNS")
        field :tftp, _("TFTP"), Fields::Reference, :details => :url
        field :dhcp, _("DHCP"), Fields::Reference, :details => :url
        field :ipam, _("IPAM")
        field :gateway, _("Gateway")
        field :from, _("From")
        field :to, _("To")
        field :mtu, _("MTU")
        HammerCLIForeman::References.domains(self)
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.parameters(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Subnet created.")
      failure_message _("Could not create the subnet")

      build_options :without => [:subnet_parameters_attributes]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

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
