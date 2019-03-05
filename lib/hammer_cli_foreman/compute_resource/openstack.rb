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

      def mandatory_resource_options
        super + [:url, :user, :password]
      end

    end
    HammerCLIForeman.register_compute_resource('openstack', OpenStack.new)
  end
end