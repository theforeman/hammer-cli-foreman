require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/associating_commands'

module HammerCLIForeman

  class PartitionTable < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Ptable

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, "Id"
        field :name, "Name"
        field :os_family, "OS Family"
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
      end

    end


    class DumpCommand < HammerCLIForeman::InfoCommand

      command_name "dump"
      desc "View partition table content."


      def print_data(partition_table)
        puts partition_table["layout"]
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--file", "LAYOUT", "Path to a file that contains the partition layout", :attribute_name => :layout, :required => true,
        :format => HammerCLI::Options::Normalizers::File.new

      success_message "Partition table created"
      failure_message "Could not create the partition table"

      apipie_options :without => [:layout] + declared_identifiers.keys
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      option "--file", "LAYOUT", "Path to a file that contains the partition layout", :attribute_name => :layout,
        :format => HammerCLI::Options::Normalizers::File.new

      success_message "Partition table updated"
      failure_message "Could not update the partition table"

      apipie_options :without => [:layout] + declared_identifiers.keys
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Partition table deleted"
      failure_message "Could not delete the partition table"
    end


    include HammerCLIForeman::AssociatingCommands::OperatingSystem


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'partition_table', "Manipulate Foreman's partition tables.", HammerCLIForeman::PartitionTable

