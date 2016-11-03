module HammerCLIForeman
  module ComputeResources
    module GCE
      class HostHelpExtenstion
        def name
          _('GCE')
        end

        def host_create_help(h)
          h.section '--compute-attributes' do |h|
            h.list([
              'machine_type',
              'image_id',
              'network',
              'external_ip'
            ])
          end
        end
      end
    end
  end
end
