module HammerCLIForeman
  module ComputeResources
    module Rackspace
      class HostHelpExtenstion
        def name
          _('oVirt')
        end

        def host_create_help(h)
          h.list([
            'flavor_id',
            'image_id'
          ])
        end
      end
    end
  end
end
