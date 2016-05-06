module HammerCLIForeman

  class PartitionTable < HammerCLIForeman::Command

    resource :ptables

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :os_family, _("OS Family")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :locked, _("Locked"), Fields::Boolean
        HammerCLIForeman::References.operating_systems(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end


    class DumpCommand < HammerCLIForeman::InfoCommand
      command_name "dump"
      desc _("View partition table content.")

      def print_data(partition_table)
        puts partition_table["layout"]
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--file", "LAYOUT", _("Path to a file that contains the partition layout"), :attribute_name => :option_layout,
        :required => true, :format => HammerCLI::Options::Normalizers::File.new

      success_message _("Partition table created")
      failure_message _("Could not create the partition table")

      build_options :without => [:layout]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      option "--file", "LAYOUT", _("Path to a file that contains the partition layout"), :attribute_name => :option_layout,
        :format => HammerCLI::Options::Normalizers::File.new

      success_message _("Partition table updated")
      failure_message _("Could not update the partition table")

      build_options :without => [:layout]
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Partition table deleted")
      failure_message _("Could not delete the partition table")

      build_options
    end


    HammerCLIForeman::AssociatingCommands::OperatingSystem.extend_command(self)


    autoload_subcommands
  end

end


