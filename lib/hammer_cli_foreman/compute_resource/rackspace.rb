module HammerCLIForeman
  module ComputeResources
    class Rackspace < Base
      def name
        _('Rackspace')
      end

      def compute_attributes
        [
            'flavor_id',
            'image_id'
        ]
      end

      def mandatory_resource_options
        super + [:url]
      end

    end
    HammerCLIForeman.register_compute_resource('rackspace', Rackspace.new)
  end
end