require 'hammer_cli_foreman/image'
require 'hammer_cli_foreman/virtual_machine'
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
      success_message _("Compute resource created.")
      failure_message _("Could not create the compute resource")

      build_options

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
      success_message _("Compute resource updated.")
      failure_message _("Could not update the compute resource")

      build_options :without => :name
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Compute resource deleted.")
      failure_message _("Could not delete the compute resource")

      build_options
    end

    class AssociateVmsCommand < HammerCLIForeman::Command
      action :associate
      command_name 'associate-vms'
      option "--vm-id","VM ID", _("Associate a specific VM")
      success_message _("Virtual machines have been associated.")
      failure_message _("Could not associate the virtual machines")

      build_options
    end

    class AvailableClustersCommand < HammerCLIForeman::ListCommand
      action :available_clusters
      command_name 'clusters'

      output do
        field :id, _('Id')
        field :name, _('Name')
        field :datacenter, _('Datacenter')
        field :num_host, _('Hosts')
        field :full_path, _('Cluster path')
      end

      build_options
    end

    class AvailableNetworksCommand < HammerCLIForeman::ListCommand
      action :available_networks
      command_name 'networks'

      output do
        field :id, _('Id'), Fields::Field, :max_width => 200, :hide_blank => true
        field :name, _('Name')
        field :datacenter, _('Datacenter')
        field :virtualswitch, _('Virtual switch')
        field :vlanid, _('VLAN ID')
      end

      build_options without: :cluster_id
      extend_with(HammerCLIForeman::CommandExtensions::ComputeResourceSubcommand.new(only: %i[option request_params]))
    end

    class AvailableImagesCommand < HammerCLIForeman::ListCommand
      action :available_images
      command_name 'images'

      output do
        field :uuid, _('Uuid')
        field :name, _('Name')
        field :path, _('Path'), Fields::Field, :hide_blank => true
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
        field :parent, _('Parent')
        field :datacenter, _('Datacenter')
        field :path, _('Path'), Fields::Field, :max_width => 50
        field :type, _('Type')
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
        field :cluster, _('Cluster')
        field :datacenter, _('Datacenter')
      end

      build_options without: :cluster_id
      extend_with(HammerCLIForeman::CommandExtensions::ComputeResourceSubcommand.new(only: %i[option request_params]))
    end

    class AvailableStorageDomainsCommand < HammerCLIForeman::ListCommand
      action :available_storage_domains
      command_name 'storage-domains'

      output do
        field :id, _('Id')
        field :name, _('Name')
      end

      build_options without: :cluster_id
      extend_with(HammerCLIForeman::CommandExtensions::ComputeResourceSubcommand.new(only: %i[option request_params]))
    end

    class AvailableStoragePodsCommand < HammerCLIForeman::ListCommand
      action :available_storage_pods
      command_name 'storage-pods'

      output do
        field :id, _('Id')
        field :name, _('Name')
        field :datacenter, _('Datacenter')
      end

      build_options without: :cluster_id
      extend_with(HammerCLIForeman::CommandExtensions::ComputeResourceSubcommand.new(only: %i[option request_params]))
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

    class AvailableVirtualMachinesCommand < HammerCLIForeman::ListCommand
      action :available_virtual_machines
      command_name 'virtual-machines'

      output do
        field :id, _('Id')
        field :name, _('Name')
        field :path, _('Path'), Fields::Field, :max_width => 50
        field :state, _('State')
      end

      build_options
    end

    autoload_subcommands
    subcommand 'virtual-machine', HammerCLIForeman::VirtualMachine.desc,
               HammerCLIForeman::VirtualMachine
    subcommand 'image', HammerCLIForeman::Image.desc, HammerCLIForeman::Image
  end

end
