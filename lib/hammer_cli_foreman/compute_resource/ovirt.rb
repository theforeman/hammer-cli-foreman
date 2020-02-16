module HammerCLIForeman
  module ComputeResources
    class Ovirt < Base
      def name
        'oVirt'
      end

      def compute_attributes
        [
          ['cluster',  _('ID or name of cluster to use')],
          ['template', _('Hardware profile to use')],
          ['cores',    _('Integer value, number of cores')],
          ['sockets',  _('Integer value, number of sockets')],
          ['memory',   _('Amount of memory, integer value in bytes')]
        ]
      end

      def host_attributes
        [
          ['start', _('Boolean, set 1 to start the vm')]
        ]
      end

      def interface_attributes
        [
          ['compute_name',      _('Compute name, e.g. eth0')],
          ['compute_network',   _('Select one of available networks for a cluster, must be an ID or a name')],
          ['compute_interface', _('Interface type')]
        ]
      end

      def volume_attributes
        [
          ['size_gb',        _('Volume size in GB, integer value')],
          ['storage_domain', _('ID or name of storage domain')],
          ['bootable',       _('Boolean, set 1 for bootable, only one volume can be bootable')],
          ['preallocate',    _('Boolean, set 1 to preallocate')],
          ['wipe_after_delete', _('Boolean, set 1 to wipe disk after delete')],
          ['interface', _('Disk interface name, must be ide, virto or virto_scsi')]
        ]
      end

      def provider_specific_fields
        super + [
          Fields::Field.new(:label => _('Datacenter'), :path => [:datacenter])
        ]
      end

      def mandatory_resource_options
        super + %i[url user password datacenter]
      end
    end

    HammerCLIForeman.register_compute_resource('ovirt', Ovirt.new)
  end
end
