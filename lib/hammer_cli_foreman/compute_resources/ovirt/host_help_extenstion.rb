module HammerCLIForeman
  module ComputeResources
    module Ovirt
      class ComputeResourceHelpExtenstion
        def name
          _('oVirt')
        end

        def host_create_help(h)
          compute_attributes_option(h,
              main_attributes_list_definition +
              [['start', _('Boolean (expressed as 0 or 1), whether to start the machine or not')]]
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
                   ['id',        _('Network ID')],
                   ['name',      _('Eg. eth0')],
                   ['network',   _('Network ID from the available networks in a cluster')],
                   ['interface', _('Select one of available interfaces type')]

          ])
        end

        def volume_properties_definition(h)
          h.list([
                   ['size_gb',           _('Volume size in GB, integer value')],
                   ['storage_domain',    _('Storage Domain ID, Select one of available storage domains')],
                   ['preallocate',       _('Boolean, (expressed as 0 or 1) preallocate=1,  thin provisioning=0')],
                   ['wipe_after_delete', _('Boolean, (expressed as 0 or 1)')],
                   ['interface',         _('Name of Disk Interface')],
                   ['bootable',          _('Boolean (expressed as 0 or 1), only one volume can be bootable')]
          ])
        end



        def main_attributes_list_definition
          [
            ['cluster',   _('Cluster ID')],
            ['template',   _('Template ID')],
            ['cores',      _('Integer value, number of cores')],
            ['sockets',    _('Integer value, number of sockets')],
            ['ha',         _('Boolean (expressed as 0 or 1), Highly Available=1')]
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
