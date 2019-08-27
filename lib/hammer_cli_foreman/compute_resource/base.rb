module HammerCLIForeman
  module ComputeResources
    class Base
      attr_reader :name
      def compute_attributes; []; end
      def interface_attributes; []; end # all attributes must start with compute_
      def volume_attributes; []; end
      def interfaces_attrs_name; "interfaces_attributes" ; end
      def mandatory_resource_options; [:name, :provider]; end
    end
  end
end