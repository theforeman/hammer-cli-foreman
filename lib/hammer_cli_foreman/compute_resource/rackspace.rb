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
  end
end