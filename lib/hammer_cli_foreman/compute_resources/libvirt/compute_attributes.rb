require 'hammer_cli_foreman/compute_resources/compute_attributes_base'

module HammerCLIForeman
  module ComputeResources
    module Libvirt
      class ComputeAttributes < ComputeAttributesBase
        def name
          'libvirt'
        end

        def fields(dsl)
          dsl.build do
            field :cpus, _('CPUs')
            field :memory, _('Memory')
            collection :nics_attributes, _("Network interfaces") do
              field :type, _('Type')
              field :bridge, _('Bridge')
            end
            # TODO: add all attributes
          end
        end
      end
    end
  end
end
