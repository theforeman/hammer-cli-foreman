require 'hammer_cli_foreman/image'

module HammerCLIForeman

  class ComputeResource < HammerCLI::Apipie::Command
    resource ForemanApi::Resources::ComputeResource

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, "Id"
        field :name, "Name"
        field :provider, "Provider"
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      PROVIDER_SPECIFIC_FIELDS = {
        'ovirt' => [
          Fields::Field.new(:label => 'UUID', :path => ["compute_resource", "uuid"])
        ],
        'ec2' => [
          Fields::Field.new(:label => 'Region', :path => ["compute_resource", "region"])
        ],
        'vmware' => [
          Fields::Field.new(:label => 'UUID', :path => ["compute_resource", "uuid"]),
          Fields::Field.new(:label => 'Server', :path => ["compute_resource", "server"])
        ],
        'openstack' => [
          Fields::Field.new(:label => 'Tenant', :path => ["compute_resource", "tenant"])
        ],
        'rackspace' => [
          Fields::Field.new(:label => 'Region', :path => ["compute_resource", "region"])
        ],
        'libvirt' => [
        ]
      }

      output ListCommand.output_definition do
        field :url, "Url"
        field :description, "Description"
        field :user, "User"
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
      end

      def print_data(data)
        provider = data["provider"].downcase
        output_definition.fields.concat PROVIDER_SPECIFIC_FIELDS[provider]
        print_collection(output_definition, data)
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Compute resource created"
      failure_message "Could not create the compute resource"

      apipie_options

      validate_options do
        all(:option_name, :option_url, :option_provider).required
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Compute resource updated"
      failure_message "Could not update the compute resource"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Compute resource deleted"
      failure_message "Could not delete the compute resource"

      apipie_options
    end


    autoload_subcommands
    subcommand 'image', HammerCLIForeman::Image.desc, HammerCLIForeman::Image
  end

end

HammerCLI::MainCommand.subcommand 'compute_resource', "Manipulate compute resources.", HammerCLIForeman::ComputeResource


