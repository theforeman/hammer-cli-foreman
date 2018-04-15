module HammerCLIForeman
  module ComputeResources
    class Base
      attr_reader :name
      def compute_attributes; []; end
      def interface_attributes; []; end
      def volume_attributes; []; end
    end
  end
end