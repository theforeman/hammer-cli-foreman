module HammerCLIForeman
  module ComputeResources
    module VMware
      class HostHelpExtenstion
        INTERFACE_TYPES = %w(
          VirtualVmxnet,
          VirtualVmxnet2,
          VirtualVmxnet3,
          VirtualE1000,
          VirtualE1000e,
          VirtualPCNet32
        )

        def name
          _('VMWare')
        end

        def host_create_help(h)
          h.section '--compute-attributes' do |h|
            h.list([
              ['cpus',                 _("Cpu count")],
              ['corespersocket',       _("Number of cores per socket (applicable to hardware versions < 10 only)")],
              ['memory_mb',            _("Integer number, amount of memory in MB")],
              ['cluster',              _("Cluster id from VMware")],
              ['path',                 _("Path to folder")],
              ['guest_id',             _("Guest OS id form VMware")],
              ['scsi_controller_type', _("Id of the controller from VMware")],
              ['hardware_version',     _("Hardware version id from VMware")],
              ['start',                _("Must be a 1 or 0, whether to start the machine or not")]
            ])
          end
          h.section '--interface' do |h|
            h.list([
              ['compute_type', interface_type_description(h)],
              ['compute_network', _('Network id from VMware')]
            ])
          end
          h.section '--volume' do |h|
            h.list([
              ['name'],
              ['datastore',  _('Datastore id from VMware')],
              ['size_gb',    _('Integer number, volume size in GB')],
              ['thin',       'true/false'],
              ['eager_zero', 'true/false']
            ])
          end
        end

        private

        def interface_type_description(h)
          [
            _('Type of the network adapter, for example one of:'),
            h.indent(INTERFACE_TYPES),
            _("See documentation center for your version of vSphere to find more details about available adapter types:"),
            h.indent("https://www.vmware.com/support/pubs/")
          ].join("\n")
        end
      end
    end
  end
end
