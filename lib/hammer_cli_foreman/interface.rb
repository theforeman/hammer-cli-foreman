module HammerCLIForeman

  class Interface < HammerCLIForeman::Command

    resource :interfaces
    desc _("View and manage host's network interfaces")

    def self.format_type(nic)
      flags = []
      flags << _('primary') if nic['primary']
      flags << _('provision') if nic['provision']

      type = nic['type']
      if !flags.empty?
        type += " (#{flags.join(', ')})"
      end
      type
    end

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :identifier, _("Identifier")
        field :_type , _("Type")
        field :mac , _("MAC address")
        field :ip , _("IP address")
        field :name , _("DNS name")
      end

      def extend_data(nic)
        nic['_type'] = HammerCLIForeman::Interface.format_type(nic)
        nic
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output do
        field :id, _("Id")
        field :identifier, _("Identifier")
        field :type , _("Type")
        field :mac , _("MAC address")
        field :ip , _("IP address")
        field :name , _("DNS name")
        field nil, _("Subnet"), Fields::SingleReference, :key => :subnet
        field nil, _("Domain"), Fields::SingleReference, :key => :domain
        field :managed, _("Managed"), Fields::Boolean
        field :primary, _("Primary"), Fields::Boolean
        field :provision, _("Provision"), Fields::Boolean
        field :virtual, _("Virtual"), Fields::Boolean
        field :tag, _("Tag"), nil, :hide_blank => true
        field :attached_to, _("Attached to"), nil, :hide_blank => true

        label _("BMC"), :hide_blank => true do
          field :username, _("Username"), nil, :hide_blank => true
          field :provider, _("Provider"), nil, :hide_blank => true
        end

        label _("Bond"), :hide_blank => true do
          field :mode, _("Mode"), nil, :hide_blank => true
          field :attached_devices, _("Attached devices"), nil, :hide_blank => true
          field :bond_options, _("Bond options"), nil, :hide_blank => true
        end
      end

      build_options
    end


    module InterfaceUpdate

      def self.included(base)
        base.option "--primary", :flag, _("Should this interface be used for constructing the FQDN of the host? Each managed hosts needs to have one primary interface.")
        base.option "--provision", :flag, _("Should this interface be used for TFTP of PXELinux (or SSH for image-based hosts)? Each managed hosts needs to have one provision interface.")
      end

      def get_interfaces(host_id)
        HammerCLIForeman.foreman_resource!(:interfaces).call(:index, {'host_id' => host_id}, request_headers, request_options)
      end

      def mandatory_interfaces(host_id, nic_id)
        mandatory_options = []
        get_interfaces(host_id)['results'].each do |nic|
          if (nic['primary'] || nic['provision']) && nic['id'] != nic_id
            mandatory_options << {
              'id' => nic['id'],
              'primary' => nic['primary'],
              'provision' => nic['provision']
            }
          end
        end
        mandatory_options
      end

      def reset_flag(interfaces_params, flag)
        interfaces_params.each do |nic|
          nic[flag] = false if nic[flag]
        end
      end

      def send_request
        nic_params = request_params
        interface = nic_params['interface']

        interface['id'] = nic_params['id'].to_i if nic_params['id']
        interface['compute_attributes'] = option_compute_attributes

        host_params = {}
        host_params['id'] = nic_params['host_id']
        host_params['host'] = {}
        host_params['host']['interfaces_attributes'] = mandatory_interfaces(nic_params['host_id'], interface['id'])

        reset_flag(host_params['host']['interfaces_attributes'], 'primary') if option_primary?
        reset_flag(host_params['host']['interfaces_attributes'], 'provision') if option_provision?

        host_params['host']['interfaces_attributes'] += [interface]

        HammerCLIForeman.foreman_resource!(:hosts).call(:update, host_params, request_headers, request_options)
      end
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Interface created")
      failure_message _("Could not create the interface")

      option "--compute-attributes", "COMPUTE_ATTRS", _("Compute resource specific attributes."),
        :format => HammerCLI::Options::Normalizers::KeyValueList.new

      include InterfaceUpdate

      build_options :without => [:primary, :provision]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Interface updated")
      failure_message _("Could not update the interface")

      option "--compute-attributes", "COMPUTE_ATTRS", _("Compute resource specific attributes."),
        :format => HammerCLI::Options::Normalizers::KeyValueList.new

      include InterfaceUpdate

      build_options :without => [:primary, :provision]
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Interface deleted")
      failure_message _("Could not delete the interface")

      build_options
    end

    autoload_subcommands
  end

end


