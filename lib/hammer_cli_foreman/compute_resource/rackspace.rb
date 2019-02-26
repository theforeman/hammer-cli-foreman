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
    end
    HammerCLIForeman.register_compute_resource('Rackspace', Rackspace.new)
  end
end