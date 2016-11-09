module HammerCLIForeman
  module ComputeResources
    module Rackspace
      class HostHelpExtenstion
        def name
          _('Rackspace')
        end

        def host_create_help(h)
          h.section '--compute-attributes' do |h|
            h.list([
              'flavor_id',
              'image_id'
            ])
          end
        end
      end
    end
  end
end
