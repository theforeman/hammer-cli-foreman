require 'hammer_cli_foreman/compute_resources/compute_attributes_base'

module HammerCLIForeman
  module ComputeResources
    module EC2
      class ComputeAttributes < ComputeAttributesBase
        def name
          'ec2'
        end

        def fields(dsl)
          dsl.build do
            field :flavor_id, _('Flavor')
            field :availability_zone, _('Zone')
            field :managed_ip, _('Managed IP')
            # TODO: add all attributes
          end
        end
      end
    end
  end
end
