module HammerCLIForeman
  module ComputeResources
    class GCE < Base
      def name
        'GCE'
      end

      def compute_attributes
        %w[machine_type network associate_external_ip]
      end

      def interfaces_attrs_name
        'network_interfaces_nics_attributes'
      end

      def volume_attributes
        [
          ['size_gb', _('Volume size in GB, integer value')]
        ]
      end

      def provider_specific_fields
        [
          Fields::Field.new(:label => _('Project'), :path => [:project]),
          Fields::Field.new(:label => _('Email'), :path => [:email]),
          Fields::Field.new(:label => _('Key Path'), :path => [:key_path]),
          Fields::Field.new(:label => _('Zone'), :path => [:zone])
        ]
      end

      def provider_vm_specific_fields
        [
          Fields::Field.new(:label => _('Machine Type'), :path => [:machine_type]),
          Fields::Field.new(:label => _('Status'), :path => [:status]),
          Fields::Field.new(:label => _('Description'), :path => [:description]),
          Fields::Field.new(:label => _('Zone'), :path => [:zone])
        ]
      end

      def mandatory_resource_options
        super + %I{project key_path zone}
      end
    end

    HammerCLIForeman.register_compute_resource('gce', GCE.new)
  end
end
