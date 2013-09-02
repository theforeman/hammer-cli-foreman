require 'hammer_cli'
require 'foreman_api'
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

      command_name "dump"
      desc "View partition table content."

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

      apipie_options :without => [:layout] + declared_identifiers.keys
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      option "--file", "LAYOUT", "Path to a file that contains the partition layout", :attribute_name => :layout, &HammerCLI::OptionFormatters.method(:file)

      success_message "Partition table updated"
      failure_message "Could not update the partition table"
      resource ForemanApi::Resources::Ptable, "update"

      apipie_options :without => [:layout] + declared_identifiers.keys
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Partition table deleted"
      failure_message "Could not delete the partition table"
      resource ForemanApi::Resources::Ptable, "destroy"
    end


    class AddOSCommand < HammerCLIForeman::AddAssociatedCommand

      resource ForemanApi::Resources::Ptable
      associated_resource ForemanApi::Resources::OperatingSystem

      associated_identifiers :id

      success_message "The operating system has been associated with the partition table"
      failure_message "Could not associate the operating system"

    end


    class RemoveOSCommand < HammerCLIForeman::RemoveAssociatedCommand

      resource ForemanApi::Resources::Ptable
      associated_resource ForemanApi::Resources::OperatingSystem

      associated_identifiers :id

      success_message "The operating system has been disassociated from the partition table"
      failure_message "Could not disassociate the operating system"

    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'partition_table', "Manipulate Foreman's partition tables.", HammerCLIForeman::PartitionTable

