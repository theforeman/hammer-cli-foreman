module HammerCLIForeman
  module ComputeResources
    module Libvirt
      class HostHelpExtenstion
        def name
          _('Libvirt')
        end

        def host_create_help(h)
          h.section '--compute-attributes' do |h|
            h.list([
              ['cpus',   _('Number of CPUs')],
              ['memory', _('String, amount of memory, value in bytes')],
              ['start',  _('Boolean (expressed as 0 or 1), whether to start the machine or not')]
            ])
          end
          h.section '--interface' do |h|
            h.list([
              ['compute_type',                     _('Possible values: %s') % 'bridge, network'],
              ['compute_network / compute_bridge', _('Name of interface according to type')],
              ['compute_model',                    _('Possible values: %s') % 'virtio, rtl8139, ne2k_pci, pcnet, e1000']
            ])
          end
          h.section '--volume' do |h|
            h.list([
              ['pool_name',   _('One of available storage pools')],
              ['capacity',    _('String value, eg. 10G')],
              ['format_type', _('Possible values: %s') % 'raw, qcow2']
            ])
          end
        end
      end
    end
  end
end
