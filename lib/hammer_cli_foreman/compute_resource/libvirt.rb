module HammerCLIForeman
  module ComputeResources
    class Libvirt < Base
      def name
        'Libvirt'
      end

      def compute_attributes
        [
          ['cpus',   _('Number of CPUs'), { bold: true }],
          ['memory', _('String, amount of memory, value in bytes'), { bold: true }],
          ['cpu_mode', _('Possible values: %{modes}') % { modes: 'default, host-model, host-passthrough' }]
        ]
      end

      def host_attributes
        [
          ['start', _('Boolean (expressed as 0 or 1), whether to start the machine or not')]
        ]
      end

      def interface_attributes
        [
          ['compute_type',   _('Possible values: %s') % 'bridge, network'],
          ['compute_bridge', _('Name of interface according to type')],
          ['compute_model',  _('Possible values: %s') % 'virtio, rtl8139, ne2k_pci, pcnet, e1000'],
          ['compute_network'], _('Libvirt instance network, e.g. default')
        ]
      end

      def volume_attributes
        [
          ['pool_name',   _('One of available storage pools'), { bold: true }],
          ['capacity',    _('String value, e.g. 10G'), { bold: true }],
          ['allocation'], _('Initial allocation, e.g. 0G'),
          ['format_type', _('Possible values: %s') % 'raw, qcow2']
        ]
      end

      def interfaces_attrs_name
        'nics_attributes'
      end

      def mandatory_resource_options
        super + %i[url]
      end
    end

    HammerCLIForeman.register_compute_resource('libvirt', Libvirt.new)
  end
end
