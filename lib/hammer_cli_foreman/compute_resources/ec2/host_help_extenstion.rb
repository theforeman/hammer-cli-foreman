module HammerCLIForeman
  module ComputeResources
    module EC2
      class HostHelpExtenstion
        def name
          _('EC2')
        end

        def host_create_help(h)
          h.section '--compute-attributes' do |h|
            h.list([
              'flavor_id',
              'image_id',
              'availability_zone',
              'security_group_ids',
              'managed_ip',
            ])
          end
        end
      end
    end
  end
end
