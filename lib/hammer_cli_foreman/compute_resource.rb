require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class ComputeResource < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::ComputeResource, "index"

      heading "Compute resource list"
      output do
        from "compute_resource" do
          field :id, "Id"
          field :name, "Name"
          field :provider, "Provider"
          field :created_at, "Created at", &HammerCLIForeman::Formatters.method(:date_formatter)
          field :updated_at, "Updated at", &HammerCLIForeman::Formatters.method(:date_formatter)
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      PROVIDER_SPECIFIC_FIELDS = {
        'ovirt' => [
          HammerCLI::Output::Definition::Field.new('uuid', 'UUID', :path => "compute_resource")
        ],
        'ec2' => [
          HammerCLI::Output::Definition::Field.new('region', 'Region', :path => "compute_resource")
        ],
        'vmware' => [
          HammerCLI::Output::Definition::Field.new('uuid', 'UUID', :path => "compute_resource"),
          HammerCLI::Output::Definition::Field.new('server', 'Server', :path => "compute_resource")
        ],
        'openstack' => [
          HammerCLI::Output::Definition::Field.new('tenant', 'Tenant', :path => "compute_resource")
        ],
        'rackspace' => [
          HammerCLI::Output::Definition::Field.new('region', 'Region', :path => "compute_resource")
        ],
        'libvirt' => [
        ]
      }

      resource ForemanApi::Resources::ComputeResource, "show"

      heading "Compute resource info"
      output ListCommand.output_definition do
        from "compute_resource" do
          field :url, "Url"
          field :description, "Description"
          field :user, "User"
        end
      end

      def print_records data
        provider = data["compute_resource"]["provider"].downcase
        output_definition.fields.concat PROVIDER_SPECIFIC_FIELDS[provider]
        super data
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Compute resource created"
      failure_message "Could not create the compute resource"
      resource ForemanApi::Resources::ComputeResource, "create"

      apipie_options

      validate_options do
        all(:name, :url, :provider).required
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Compute resource updated"
      failure_message "Could not update the compute resource"
      resource ForemanApi::Resources::ComputeResource, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Compute resource deleted"
      failure_message "Could not delete the compute resource"
      resource ForemanApi::Resources::ComputeResource, "destroy"

      apipie_options
    end

    subcommand "list", "List architectures.", HammerCLIForeman::ComputeResource::ListCommand
    subcommand "info", "Detailed info about an architecture.", HammerCLIForeman::ComputeResource::InfoCommand
    subcommand "create", "Create new architecture.", HammerCLIForeman::ComputeResource::CreateCommand
    subcommand "update", "Update an architecture.", HammerCLIForeman::ComputeResource::UpdateCommand
    subcommand "delete", "Delete an architecture.", HammerCLIForeman::ComputeResource::DeleteCommand
  end

end

HammerCLI::MainCommand.subcommand 'compute_resource', "Manipulate Foreman's architectures.", HammerCLIForeman::ComputeResource

