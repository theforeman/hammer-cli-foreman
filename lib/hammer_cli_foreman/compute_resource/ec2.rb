module HammerCLIForeman
  module ComputeResources
    class EC2 < Base
      def name
        _('EC2')
      end

      def compute_attributes
        [
            'flavor_id',
            'image_id',
            'availability_zone',
            'security_group_ids',
            'managed_ip'
        ]
      end
    end
  end
end