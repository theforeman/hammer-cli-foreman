module HammerCLIForeman
  module ComputeResources
    module Ovirt
      class HostHelpExtenstion
        def name
          _('oVirt')
        end

        def host_create_help(h)
          h.section '--compute-attributes' do |h|
            h.list([
              ['cluster', _('ID of cluster to use')],
              ['template', _('Hardware profile to use')],
              ['cores',    _('Integer value, number of cores')],
              ['memory',   _('Amount of memory, integer value in bytes')],
              ['start',    _('Boolean (expressed as 0 or 1), whether to start the machine or not')]
            ])
          end
          h.section '--interface' do |h|
            h.list([
              ['compute_name',    _('Eg. eth0')],
              ['compute_network', _('Select one of available networks for a cluster, must be an ID')]
            ])
          end
          h.section '--volume' do |h|
            h.list([
              ['size_gb',        _('Volume size in GB, integer value')],
              ['storage_domain', _('ID of storage domain')],
              ['bootable',       _('Boolean, only one volume can be bootable')]
            ])
          end
        end
      end
    end
  end
end
