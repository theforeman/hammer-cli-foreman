module HammerCLIForeman
  module ComputeResources
    class Ovirt < Base
      def name
        'oVirt'
      end

      def compute_attributes
        [
          ['cluster',  _('ID of cluster to use')],
          ['template', _('Hardware profile to use')],
          ['cores',    _('Integer value, number of cores')],
          ['sockets',  _('Integer value, number of sockets')],
          ['memory',   _('Amount of memory, integer value in bytes')]
        ]
      end

      def host_attributes
        [
          ['start', _('Boolean (expressed as 0 or 1), whether to start the machine or not')]
        ]
      end

      def interface_attributes
        [
          ['compute_name',      _('Compute name, e.g. eth0')],
          ['compute_network',   _('Select one of available networks for a cluster, must be an ID')],
          ['compute_interface', _('Interface type')]
        ]
      end

      def volume_attributes
        [
          ['size_gb',        _('Volume size in GB, integer value')],
          ['storage_domain', _('ID of storage domain')],
          ['bootable',       _('Boolean, only one volume can be bootable')],
          ['preallocate',    _('Boolean, set %s to preallocate') % 'true'],
          ['wipe_after_delete', _('Boolean, set %s to wipe disk after delete') % 'true'],
          ['interface', _('Disk interface name, must be ide, virto or virto_scsi')]
        ]
      end

      def provider_specific_fields
        [
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
