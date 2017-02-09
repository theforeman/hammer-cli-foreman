module HammerCLIForeman
  module ComputeResources
    class ComputeAttributesBase
      def name
      end

      def fields(dsl)
      end

      def transform_attributes(attrs)
        attrs['nics_attributes'] = attrs['nics_attributes'].values if attrs.has_key?('nics_attributes')
        attrs['volumes_attributes'] = attrs['volumes_attributes'].values if attrs.has_key?('volumes_attributes')
        attrs
      end
    end
  end
end
