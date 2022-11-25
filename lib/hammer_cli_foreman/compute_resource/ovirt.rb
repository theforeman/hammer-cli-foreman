module HammerCLIForeman
  module ComputeResources
    class Ovirt < Base
      def name
        'oVirt'
      end

      def compute_attributes
        [
          ['cluster',         _('ID or name of cluster to use')],
          ['template',        _('Hardware profile to use')],
          ['cores',           _('Integer value, number of cores')],
          ['sockets',         _('Integer value, number of sockets')],
          ['memory',          _('Amount of memory, integer value in bytes')],
          ['ha',              _('Boolean, set 1 to high availability')],
          ['display_type',    _('Possible values: %s') % 'VNC, SPICE'],
          ['keyboard_layout', _('Possible values: %s. Not usable if display type is SPICE.') % 'ar, de-ch, es, fo, fr-ca, hu, ja, mk, no, pt-br, sv, da, en-gb, et, fr, fr-ch, is, lt, nl, pl, ru, th, de, en-us, fi, fr-be, hr, it, lv, nl-be, pt, sl, tr']
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
          ['compute_interface', _('Interface type')],
          ['compute_vnic_profile', _('Vnic Profile')]
        ]
      end

      def volume_attributes
        [
          ['size_gb',        _('Volume size in GB, integer value')],
          ['storage_domain', _('ID or name of storage domain')],
          ['bootable',       _('Boolean, set 1 for bootable, only one volume can be bootable')],
          ['preallocate',    _('Boolean, set 1 to preallocate')],
          ['wipe_after_delete', _('Boolean, set 1 to wipe disk after delete')],
          ['interface', _('Disk interface name, must be ide, virtio or virtio_scsi')]
        ]
      end

      def provider_specific_fields
        super + [
          Fields::Field.new(:label => _('Datacenter'), :path => [:datacenter])
        ]
      end

      def provider_vm_specific_fields
        [
          Fields::Field.new(:label => _('CPUs'), :path => [:cpu]),
          Fields::Field.new(:label => _('Memory'), :path => [:memory]),
          Fields::Field.new(:label => _('Status'), :path => [:status]),
          Fields::Field.new(:label => _('Cores'), :path => [:cores]),
          Fields::Field.new(:label => _('Type'), :path => [:type])
        ]
      end

      def mandatory_resource_options
        super + %i[url user password datacenter]
      end
    end

    HammerCLIForeman.register_compute_resource('ovirt', Ovirt.new)
  end
end
