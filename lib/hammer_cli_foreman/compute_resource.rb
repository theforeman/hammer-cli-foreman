require 'hammer_cli_foreman/image'

module HammerCLIForeman

  class ComputeResource < HammerCLIForeman::Command
    resource :compute_resources

    module ProviderNameLegacy
      def extend_data(data)
        # api used to return provider_friendly_name as a provider
        data['provider_friendly_name'] ||= data['provider']
        data
      end
    end

    class ListCommand < HammerCLIForeman::ListCommand
      include ProviderNameLegacy

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :provider_friendly_name, _("Provider")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      include ProviderNameLegacy

      PROVIDER_SPECIFIC_FIELDS = {
        'ovirt' => [
          Fields::Field.new(:label => _('Datacenter'), :path => [:datacenter])
        ],
        'ec2' => [
          Fields::Field.new(:label => _('Region'), :path => [:region])
        ],
        'vmware' => [
          Fields::Field.new(:label => _('Datacenter'), :path => [:datacenter]),
          Fields::Field.new(:label => _('Server'), :path => [:server])
        ],
        'openstack' => [
          Fields::Field.new(:label => _('Tenant'), :path => [:tenant])
        ],
        'rackspace' => [
          Fields::Field.new(:label => _('Region'), :path => [:region])
        ],
        'libvirt' => [
        ]
      }

      output ListCommand.output_definition do
        field :url, _("Url")
        field :description, _("Description")
        field :user, _("User")
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      def print_data(data)
        provider = data["provider"].downcase
        output_definition.fields.concat(PROVIDER_SPECIFIC_FIELDS[provider] || [])
        super(data)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Compute resource created")
      failure_message _("Could not create the compute resource")

      build_options

      validate_options do
        all(:option_name, :option_url, :option_provider).required
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
    subcommand 'image', HammerCLIForeman::Image.desc, HammerCLIForeman::Image
  end

end


