module HammerCLIForeman
  module ComputeResources
    class Ovirt < Base
      def name
        _('oVirt')
      end

      def compute_attributes
        [
            ['cluster'],
            ['template', _('Hardware profile to use')],
            ['cores',    _('Integer value, number of cores')],
            ['memory',   _('Amount of memory, integer value in bytes')],
            ['start',    _('Boolean (expressed as 0 or 1), whether to start the machine or not')]
        ]
      end

      def interface_attributes
        [
            ['compute_name',    _('Eg. eth0')],
            ['compute_network', _('Select one of available networks for a cluster')]
        ]
      end

      def volume_attributes;
        [
            ['size_gb',        _('Volume size in GB, integer value')],
            ['storage_domain', _('Select one of available storage domains')],
            ['bootable',       _('Boolean, only one volume can be bootable')]
        ]
      end
    end
  end
end