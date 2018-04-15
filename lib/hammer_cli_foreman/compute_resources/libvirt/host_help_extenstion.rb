module HammerCLIForeman
  module ComputeResources
    module Libvirt
      class ComputeResourceHelpExtenstion
        def name
          _('Libvirt')
        end

        def host_create_help(h)
          compute_attributes_option(h,
                                    main_attributes_list_definition +
                                      ['start', _('Boolean (expressed as 0 or 1), whether to start the machine or not')]
          )
          h.section '--interface' do |h|
            interface_properties_definition(h)
          end
          h.section '--volume' do |h|
            volume_properties_definition(h)
          end
        end

        def compute_profile_create_help(h)
          compute_attributes_option(h, main_attributes_list_definition)
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
                   ['compute_type',                     _('Possible values: %s') % 'bridge, network'],
                   ['compute_network / compute_bridge', _('Name of interface according to type')],
                   ['compute_model',                    _('Possible values: %s') % 'virtio, rtl8139, ne2k_pci, pcnet, e1000']
                 ])
        end

        def volume_properties_definition(h)
          h.list([
                   ['pool_name',   _('One of available storage pools')],
                   ['capacity',    _('String value, eg. 10G')],
                   ['format_type', _('Possible values: %s') % 'raw, qcow2']
                 ])
        end

        def main_attributes_list_definition
          [
            ['cpus',   _('Number of CPUs')],
            ['memory', _('String, amount of memory, value in bytes')],
          ]
        end

        def compute_attributes_option(h, sub_options_list)
          h.section '--compute-attributes' do |h|
            h.list(sub_options_list)
          end
        end
      end
    end
  end
end
