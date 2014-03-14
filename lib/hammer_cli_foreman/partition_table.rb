module HammerCLIForeman

  class PartitionTable < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Ptable

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :os_family, _("OS Family")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      apipie_options
    end


    class DumpCommand < HammerCLIForeman::InfoCommand

      command_name "dump"
      desc _("View partition table content.")

      def print_data(partition_table)
        puts partition_table["layout"]
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--file", "LAYOUT", _("Path to a file that contains the partition layout"), :attribute_name => :option_layout,
        :required => true, :format => HammerCLI::Options::Normalizers::File.new

      success_message _("Partition table created")
      failure_message _("Could not create the partition table")

      apipie_options :without => [:layout] + declared_identifiers.keys
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      option "--file", "LAYOUT", _("Path to a file that contains the partition layout"), :attribute_name => :option_layout,
        :format => HammerCLI::Options::Normalizers::File.new

      success_message _("Partition table updated")
      failure_message _("Could not update the partition table")

      apipie_options :without => [:layout] + declared_identifiers.keys
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Partition table deleted")
      failure_message _("Could not delete the partition table")

      apipie_options
    end


    include HammerCLIForeman::AssociatingCommands::OperatingSystem


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'partition_table', _("Manipulate partition tables."), HammerCLIForeman::PartitionTable

