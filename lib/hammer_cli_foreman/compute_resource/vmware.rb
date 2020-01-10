module HammerCLIForeman
  module ComputeResources
    class VMware < Base
      INTERFACE_TYPES = %w[VirtualVmxnet3 VirtualE1000]

      def name
        'VMware'
      end

      def compute_attributes
        [
          ['cluster',              _('Cluster ID from VMware'), { bold: true }],
          ['corespersocket',       _('Number of cores per socket (applicable to hardware versions < 10 only)'), { bold: true }],
          ['cpus',                 _('CPU count'), { bold: true }],
          ['memory_mb',            _('Integer number, amount of memory in MB'), { bold: true }],
          ['path',                 _('Path to folder'), { bold: true }],
          ['resource_pool',        _('Resource Pool ID from VMware'), { bold: true }],
          ['firmware',             'automatic/bios/efi'],
          ['guest_id',             _('Guest OS ID form VMware')],
          ['hardware_version',     _('Hardware version ID from VMware')],
          ['memoryHotAddEnabled',  _('Must be a 1 or 0, lets you add CPU resources while the machine is on')],
          ['cpuHotAddEnabled',     _('Must be a 1 or 0, lets you add memory resources while the machine is on')],
          ['add_cdrom',            _('Must be a 1 or 0, Add a CD-ROM drive to the virtual machine')],
          ['annotation',           _('Annotation Notes')],
          ['scsi_controllers',     [_('List with SCSI controllers definitions'),
                                    '  type - ' + _('ID of the controller from VMware'),
                                    '  key  - ' + _('Key of the controller (e.g. 1000)')
                                    ].flatten(1).join("\n")]
        ]
      end

      def host_attributes
        [
          ['start', _('Must be a 1 or 0, whether to start the machine or not')]
        ]
      end

      def volume_attributes
        [
          ['name'],
          ['storage_pod',    _('Storage Pod ID from VMware')],
          ['datastore',      _('Datastore ID from VMware')],
          ['mode',           'persistent/independent_persistent/independent_nonpersistent'],
          ['size_gb',        _('Integer number, volume size in GB')],
          ['thin',           'true/false'],
          ['eager_zero',     'true/false'],
          ['controller_key', 'Associated SCSI controller key']
        ]
      end

      def interface_attributes
        [
          ['compute_type', [
            _('Type of the network adapter, for example one of:'),
            INTERFACE_TYPES.map { |it| '  ' + it },
            _('See documentation center for your version of vSphere to find more details about available adapter types:'),
            '  https://www.vmware.com/support/pubs/'
          ].flatten(1).join("\n")],
          ['compute_network', _('Network ID from VMware')]
        ]
      end

      def provider_specific_fields
        super + [
          Fields::Field.new(:label => _('Datacenter'), :path => [:datacenter]),
          Fields::Field.new(:label => _('Server'), :path => [:server])
        ]
      end

      def mandatory_resource_options
        super + %i[user password datacenter server]
      end
    end

    HammerCLIForeman.register_compute_resource('vmware', VMware.new)
  end
end
