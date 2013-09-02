require 'hammer_cli'
require 'foreman_api'
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
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      PROVIDER_SPECIFIC_FIELDS = {
        'ovirt' => [
          HammerCLI::Output::DataField.new(:label => 'UUID', :path => ["compute_resource", "uuid"])
        ],
        'ec2' => [
          HammerCLI::Output::DataField.new(:label => 'Region', :path => ["compute_resource", "region"])
        ],
        'vmware' => [
          HammerCLI::Output::DataField.new(:label => 'UUID', :path => ["compute_resource", "uuid"]),
          HammerCLI::Output::DataField.new(:label => 'Server', :path => ["compute_resource", "server"])
        ],
        'openstack' => [
          HammerCLI::Output::DataField.new(:label => 'Tenant', :path => ["compute_resource", "tenant"])
        ],
        'rackspace' => [
          HammerCLI::Output::DataField.new(:label => 'Region', :path => ["compute_resource", "region"])
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
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
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

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'compute_resource', "Manipulate Foreman's compute resources.", HammerCLIForeman::ComputeResource

