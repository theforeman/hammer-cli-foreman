module HammerCLIForeman
  module ComputeResources
    class Rackspace < Base
      def name
        'Rackspace'
      end

      def compute_attributes
        %w[flavor_id image_id]
      end

      def mandatory_resource_options
        super + %i[url]
      end
    end

    HammerCLIForeman.register_compute_resource('rackspace', Rackspace.new)
  end
end
