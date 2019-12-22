module HammerCLIForeman
  module ComputeResources
    class Base
      def name; ''; end
      def compute_attributes; []; end
      def interface_attributes; []; end # all attributes must start with compute_
      def volume_attributes; []; end
      def interfaces_attrs_name; 'interfaces_attributes'; end
      def host_attributes; []; end
      def provider_specific_fields
        [
          Fields::Field.new(label: _('Url'), path: [:url]) 
        ]
      end
      def mandatory_resource_options; %i[name provider]; end
    end
  end
end
