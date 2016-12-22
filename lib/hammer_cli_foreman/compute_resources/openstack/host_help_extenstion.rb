module HammerCLIForeman
  module ComputeResources
    module OpenStack
      class HostHelpExtenstion
        def name
          _('OpenStack')
        end

        def host_create_help(h)
          h.section '--compute-attributes' do |h|
            h.list([
              'flavor_ref',
              'image_ref',
              'tenant_id',
              'security_groups',
              'network'
            ])
          end
        end
      end
    end
  end
end
