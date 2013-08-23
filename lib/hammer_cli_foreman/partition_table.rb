require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class PartitionTable < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand

      heading "Partition table list"
      output do
        from "ptable" do
          field :id, "Id"
          field :name, "Name"
          field :os_family, "OS Family"
        end
      end

      resource ForemanApi::Resources::Ptable, "index"
      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      heading "Partition table info"
      output ListCommand.output_definition do
        from "ptable" do
          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
        end
      end

      resource ForemanApi::Resources::Ptable, "show"
    end


    class DumpCommand < HammerCLIForeman::InfoCommand

      resource ForemanApi::Resources::Ptable, "show"

      def print_data(partition_table)
        puts partition_table["ptable"]["layout"]
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--file", "LAYOUT", "Path to a file that contains the partition layout", :attribute_name => :layout, :required => true, &HammerCLI::OptionFormatters.method(:file)

      success_message "Partition table created"
      failure_message "Could not create the partition table"
      resource ForemanApi::Resources::Ptable, "create"

      apipie_options :without => [:layout] + declared_identifiers
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      option "--file", "LAYOUT", "Path to a file that contains the partition layout", :attribute_name => :layout, &HammerCLI::OptionFormatters.method(:file)

      success_message "Partition table updated"
      failure_message "Could not update the partition table"
      resource ForemanApi::Resources::Ptable, "update"

      apipie_options :without => [:layout] + declared_identifiers
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Partition table deleted"
      failure_message "Could not delete the partition table"
      resource ForemanApi::Resources::Ptable, "destroy"
    end

    subcommand "list", "List partition tables.", HammerCLIForeman::PartitionTable::ListCommand
    subcommand "info", "Detailed info about a partition table.", HammerCLIForeman::PartitionTable::InfoCommand
    subcommand "dump", "View partition table content.", HammerCLIForeman::PartitionTable::DumpCommand
    subcommand "create", "Create a new partition table.", HammerCLIForeman::PartitionTable::CreateCommand
    subcommand "update", "Update a partition table.", HammerCLIForeman::PartitionTable::UpdateCommand
    subcommand "delete", "Delete a partition table.", HammerCLIForeman::PartitionTable::DeleteCommand

  end

end

HammerCLI::MainCommand.subcommand 'partition_table', "Manipulate Foreman's partition tables.", HammerCLIForeman::PartitionTable

