module HammerCLIForeman
  module ComputeResources
    class Ovirt < Base
      def name
        _('oVirt')
      end

      def compute_attributes
        [
            ['cluster', _('ID of cluster to use')],
            ['template', _('Hardware profile to use')],
            ['cores',    _('Integer value, number of cores')],
            ['memory',   _('Amount of memory, integer value in bytes')],
        ]
      end

      def host_attributes
        [
            ['start',    _('Boolean (expressed as 0 or 1), whether to start the machine or not')]

        ]
      end

      def interface_attributes
        [
            ['name',    _('compute name, Eg. eth0')],
            ['network', _('Select one of available networks for a cluster, must be an ID')],
            ['interface', ('interface type')]
        ]
      end

      def volume_attributes;
        [
            ['size_gb',        _('Volume size in GB, integer value')],
            ['storage_domain', _('ID of storage domain')],
            ['bootable',       _('Boolean, only one volume can be bootable')]
        ]
      end
    end
    HammerCLIForeman.register_compute_resource('oVirt', Ovirt.new)
  end
end