module HammerCLIForeman
  module ComputeResources
    module VMware
      class ComputeResourceHelpExtenstion
        INTERFACE_TYPES = %w(
          VirtualVmxnet3,
          VirtualE1000
        )

        def name
          _('VMware')
        end

        def host_create_help(h)
          compute_attributes_option(h,
                                    main_attributes_list_definition + ['storage_pod', _('Storage Pod ID from VMware')]

          )
          h.section '--interface' do |h|
            interface_properties_definition(h)
          end
          h.section '--volume' do |h|
            volume_properties_definition(h)
          end
        end

        def compute_profile_create_help(h)
          compute_attributes_option(h,main_attributes_list_definition)
          h.section '--interface' do |h|
            interface_properties_definition(h)
          end
          h.section '--volume' do |h|
            volume_properties_definition(h)
          end
        end

        def interface_create_help(h)
          h.section '--set-values' do |h|
            interface_properties_definition(h)
          end
        end

        def volume_create_help(h)
          h.section '--set_values' do |h|
            volume_properties_definition(h)
          end
        end

        def interface_properties_definition(h)
          h.list([
                   ['compute_type', interface_type_description(h)],
                   ['compute_network', _('Network id from VMware')]
                 ])
        end

        def volume_properties_definition(h)
          h.list([
                   ['name'],
                   ['storage_pod', _('Storage Pod ID from VMware')],
                   ['datastore',   _('Datastore ID from VMware')],
                   ['size_gb',     _('Integer number, volume size in GB')],
                   ['thin',        'true/false'],
                   ['eager_zero',  'true/false'],
                   ['mode',        'persistent/independent_persistent/independent_nonpersistent']
                 ])
        end

        def main_attributes_list_definition
          [
            ['cpus',                 _('CPU count')],
            ['corespersocket',       _('Number of cores per socket (applicable to hardware versions < 10 only)')],
            ['memory_mb',            _('Integer number, amount of memory in MB')],
            ['firmware',             _('automatic/bios/efi')],
            ['cluster',              _('Cluster ID from VMware')],
            ['resource_pool',        _('Resource Pool ID from VMware')],
            ['path',                 _('Path to folder')],
            ['guest_id',             _('Guest OS ID form VMware')],
            ['scsi_controller_type', _('ID of the controller from VMware')],
            ['hardware_version',     _('Hardware version ID from VMware')],
            ['add_cdrom',            _('Must be a 1 or 0, Add a CD-ROM drive to the virtual machine')],
            ['cpuHotAddEnabled',     _('Must be a 1 or 0, lets you add memory resources while the machine is on')],
            ['memoryHotAddEnabled',  _('Must be a 1 or 0, lets you add CPU resources while the machine is on')],
            ['annotation',           _('Annotation Notes')],
          ]
        end

        def compute_attributes_option(h, sub_options_list)
          h.section '--compute-attributes' do |h|
            h.list(sub_options_list)
          end
        end

        private

        def interface_type_description(h)
          [
            _('Type of the network adapter, for example one of:'),
            h.indent(INTERFACE_TYPES),
            _("See documentation center for your version of vSphere to find more details about available adapter types:"),
            h.indent('https://www.vmware.com/support/pubs/')
          ].join("\n")
        end
      end
    end
  end
end
