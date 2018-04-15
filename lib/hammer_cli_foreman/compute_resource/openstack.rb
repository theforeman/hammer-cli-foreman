module HammerCLIForeman
  module ComputeResources
    class OpenStack < Base
      def name
        _('OpenStack')
      end

      def compute_attributes
        [
            'flavor_ref',
            'image_ref',
            'tenant_id',
            'security_groups',
            'network'
        ]
      end
    end
  end
end