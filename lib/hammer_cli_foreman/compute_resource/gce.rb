module HammerCLIForeman
  module ComputeResources
    class GCE < Base
      def name
        _('GCE')
      end

      def compute_attributes
        [
            'machine_type',
            'image_id',
            'network',
            'external_ip'
        ]
      end
    end
  end
end