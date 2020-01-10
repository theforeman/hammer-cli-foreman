module HammerCLIForeman
  module ComputeResources
    class EC2 < Base
      def name
        'EC2'
      end

      def compute_attributes
        %w[availability_zone flavor_id groups security_group_ids managed_ip]
      end

      def provider_specific_fields
        super + [
          Fields::Field.new(:label => _('Region'), :path => [:region])
        ]
      end

      def mandatory_resource_options
        super + %i[region user password]
      end
    end

    HammerCLIForeman.register_compute_resource('ec2', EC2.new)
  end
end
