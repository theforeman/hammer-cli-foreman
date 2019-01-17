module HammerCLIForeman
  module ComputeResources
    class VMware < Base
      INTERFACE_TYPES = %w(
           VirtualVmxnet3,
           VirtualE1000
         )

      def name
        _('VMware')
      end

      def compute_attributes
        [
            ['cpus',                 _('CPU count')],
            ['corespersocket',       _('Number of cores per socket (applicable to hardware versions < 10 only)')],
            ['memory_mb',            _('Integer number, amount of memory in MB')],
            ['firmware',             'automatic/bios/efi'],
            ['cluster',              _('Cluster ID from VMware')],
            ['resource_pool',        _('Resource Pool ID from VMware')],
            ['path',                 _('Path to folder')],
            ['guest_id',             _('Guest OS ID form VMware')],
            ['scsi_controller_type', _('ID of the controller from VMware')],
            ['hardware_version',     _('Hardware version ID from VMware')],
            ['add_cdrom',            _('Must be a 1 or 0, Add a CD-ROM drive to the virtual machine')],
            ['cpuHotAddEnabled',     _('Must be a 1 or 0, lets you add memory resources while the machine is on')],
            ['memoryHotAddEnabled',  _('Must be a 1 or 0, lets you add CPU resources while the machine is on')],
            ['start',                _("Must be a 1 or 0, whether to start the machine or not")],
            ['annotation',           _("Annotation Notes")]
        ]
      end

      def interface_attributes
        [
            ['compute_type', [
                _('Type of the network adapter, for example one of:'),
                INTERFACE_TYPES.map { |it| '  ' + it },
                _('See documentation center for your version of vSphere to find more details about available adapter types:'),
                '  https://www.vmware.com/support/pubs/'].flatten(1).join("\n") ] ,
            ['compute_network', _('Network ID from VMware')]
        ]
      end

      def volume_attributes;
        [
            ['name'],
            ['storage_pod', _('Storage Pod ID from VMware')],
            ['datastore',   _('Datastore ID from VMware')],
            ['size_gb',     _('Integer number, volume size in GB')],
            ['thin',        'true/false'],
            ['eager_zero',  'true/false'],
            ['mode',        'persistent/independent_persistent/independent_nonpersistent']
        ]
      end
    end
    HammerCLIForeman.register_compute_resource('vmware', VMware.new)
  end
end