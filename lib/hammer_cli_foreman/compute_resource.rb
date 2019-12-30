require 'hammer_cli_foreman/image'
require 'hammer_cli_foreman/compute_resource/register_compute_resources'

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

      output ListCommand.output_definition do
        field :url, _("Url")
        field :description, _("Description")
        field :user, _("User")
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      def print_data(data)
        provider = ::HammerCLIForeman.compute_resources[data['provider'].downcase]
        if provider
          output_definition.fields.concat(provider.provider_specific_fields || [])
          super(data)
        end
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      option "--public-key-path", "PUBLIC_KEY_PATH", _("Path to a file that contains oVirt public key (For oVirt only)"),
             :format => HammerCLI::Options::Normalizers::File.new


      success_message _("Compute resource created.")
      failure_message _("Could not create the compute resource")

      build_options

      def request_params
        params = super
        params['compute_resource']['public_key'] = option_public_key_path if option_public_key_path
        params
      end

      validate_options do
        if option(:option_provider).value.nil? || option(:option_name).value.nil?
          all(:option_name, :option_provider).required
        else
          provider = ::HammerCLIForeman.compute_resources[option(:option_provider).value.to_s.downcase]
          if provider
            required_options = provider.mandatory_resource_options.map { |attr| "option_#{attr}".to_sym }
            all(*required_options).required
          else
            raise ArgumentError, "incorrect/invalid --provider option"
          end
        end
      end
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      option "--public-key-path", "PUBLIC_KEY_PATH", _("Path to a file that contains oVirt public key (For oVirt only)"),
             :format => HammerCLI::Options::Normalizers::File.new

      success_message _("Compute resource updated.")
      failure_message _("Could not update the compute resource")

      def request_params
        params = super
        params['compute_resource']['public_key'] = option_public_key_path if option_public_key_path
        params
      end
      build_options :without => :name
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Compute resource deleted.")
      failure_message _("Could not delete the compute resource")

      build_options
    end

    class AvailableClustersCommand < HammerCLIForeman::ListCommand
      action :available_clusters
      command_name 'clusters'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class AvailableNetworksCommand < HammerCLIForeman::ListCommand
      action :available_networks
      command_name 'networks'

      output do
        field :id, _('Id'), Fields::Field, :max_width => 200, :hide_blank => true
        field :name, _('Name')
      end

      build_options
    end

    class AvailableImagesCommand < HammerCLIForeman::ListCommand
      action :available_images
      command_name 'images'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class AvailableFlavorsCommand < HammerCLIForeman::ListCommand
      action :available_flavors
      command_name 'flavors'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class AvailableFoldersCommand < HammerCLIForeman::ListCommand
      action :available_folders
      command_name 'folders'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class AvailableZonesCommand < HammerCLIForeman::ListCommand
      action :available_zones
      command_name 'zones'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class AvailableResourcePoolsCommand < HammerCLIForeman::ListCommand
      action :available_resource_pools
      command_name 'resource-pools'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class AvailableStorageDomainsCommand < HammerCLIForeman::ListCommand
      action :available_storage_domains
      command_name 'storage-domains'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class AvailableStoragePodsCommand < HammerCLIForeman::ListCommand
      action :available_storage_pods
      command_name 'storage-pods'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    class AvailableSecurityGroupsCommand < HammerCLIForeman::ListCommand
      action :available_security_groups
      command_name 'security-groups'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options
    end

    autoload_subcommands
    subcommand 'image', HammerCLIForeman::Image.desc, HammerCLIForeman::Image
  end

end
