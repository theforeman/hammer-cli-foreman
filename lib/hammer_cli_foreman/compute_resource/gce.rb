module HammerCLIForeman
  module ComputeResources
    class GCE < Base
      def name
        'GCE'
      end

      def compute_attributes
        %w[machine_type image_id network associate_external_ip]
      end

      def interfaces_attrs_name
        'network_interfaces_nics_attributes'
      end

      def volume_attributes
        [
          ['size_gb', _('Volume size in GB, integer value')]
        ]
      end

      def mandatory_resource_options
        super + %I{project key_path zone}
      end
    end

    HammerCLIForeman.register_compute_resource('gce', GCE.new)
  end
end
