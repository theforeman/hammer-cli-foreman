require 'hammer_cli_foreman/image'
require 'hammer_cli_foreman/compute_resources/all'

module HammerCLIForeman

  class ComputeProfile < HammerCLIForeman::Command
    resource :compute_profiles

    def self.provider_attributes
      @provider_attributes ||= {
        'libvirt' => HammerCLIForeman::ComputeResources::Libvirt::ComputeAttributes.new,
        'ec2' => HammerCLIForeman::ComputeResources::EC2::ComputeAttributes.new,
        'default' => HammerCLIForeman::ComputeResources::Default::ComputeAttributes.new
      }
    end

    def self.get_provider(name)
      provider_attributes[name] || provider_attributes['default']
    end

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      def self.vm_attrs_fields(dsl)
        dsl.build do
          HammerCLIForeman::ComputeProfile.provider_attributes.each do |k,t|
            custom_field Fields::Label, :label => _("VM attributes"), :path => ["#{t.name}_vm_attrs".to_sym], :hide_blank => true do
              t.fields(self)
            end
          end
        end
      end

      output ListCommand.output_definition do

        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)

        collection :compute_attributes, _("Compute attributes") do
          field :id, _('Id')
          field :name, _('Name')
          field nil, _("Compute Resource"), Fields::SingleReference, :key => :compute_resource
          field :provider_friendly_name, _('Provider type')
          # field :vm_attrs, _("VM attributes original")

          InfoCommand.vm_attrs_fields(self)
        end
      end

      def extend_data(record)
        record['compute_attributes'].each do |attrs|
          provider_name = attrs.fetch('provider_friendly_name', 'default')
          transformer = HammerCLIForeman::ComputeProfile.get_provider(provider_name.downcase)
          attrs[transformer.name + '_vm_attrs'] = transformer.transform_attributes(attrs['vm_attrs'])
          attrs
        end
        record
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Compute resource created")
      failure_message _("Could not create the compute resource")

      build_options

      validate_options do
        all(:option_name).required
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Compute resource updated")
      failure_message _("Could not update the compute resource")

      build_options :without => :name
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Compute resource deleted")
      failure_message _("Could not delete the compute resource")

      build_options
    end

    autoload_subcommands
  end

end


