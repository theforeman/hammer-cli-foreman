module HammerCLIForeman
  module ComputeResources
    class OpenStack < Base
      def name
        'OpenStack'
      end

      def compute_attributes
        %w[availability_zone boot_from_volume flavor_ref image_ref tenant_id security_groups network]
      end

      def provider_specific_fields
        super + [
          Fields::Field.new(:label => _('Tenant'), :path => [:tenant]),
          Fields::Field.new(:label => _('Project domain name'), :path => [:project_domain_name]),
          Fields::Field.new(:label => _('Project domain ID'), :path => [:project_domain_id])
        ]
      end

      def mandatory_resource_options
        super + %i[url user password]
      end

      def provider_vm_specific_fields
        [
          Fields::Field.new(:label => _('State'), :path => [:state]),
          Fields::Field.new(:label => _('Tenant Id'), :path => [:tenant_id])
        ]
      end
    end

    HammerCLIForeman.register_compute_resource('openstack', OpenStack.new)
  end
end
