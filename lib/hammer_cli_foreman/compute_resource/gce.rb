module HammerCLIForeman
  module ComputeResources
    class GCE < Base
      def name
        'GCE'
      end

      def compute_attributes
        %w[machine_type image_id network external_ip]
      end

      def interfaces_attrs_name
        'network_interfaces_nics_attributes'
      end
    end

    HammerCLIForeman.register_compute_resource('gce', GCE.new)
  end
end
