module HammerCLIForeman

  class ReportTemplate < HammerCLIForeman::Command
    resource :report_templates

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :locked, _("Locked"), Fields::Boolean
        HammerCLIForeman::References.timestamps(self)
        HammerCLIForeman::References.taxonomies(self)
      end

      build_options
    end


    class DumpCommand < HammerCLIForeman::InfoCommand
      command_name "dump"
      desc _("View report content")

      def print_data(report_template)
        puts report_template["template"]
      end

      build_options
    end


    class GenerateCommand < HammerCLIForeman::DownloadCommand
      command_name "generate"
      action :generate
      desc _("Generate report")

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--file", "LAYOUT", _("Path to a file that contains the report template content"), :attribute_name => :option_template,
        :required => true, :format => HammerCLI::Options::Normalizers::File.new

      success_message _("Report template created.")
      failure_message _("Could not create the report template")

      build_options :without => [:template]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      option "--file", "LAYOUT", _("Path to a file that contains the report template content"), :attribute_name => :option_template,
        :format => HammerCLI::Options::Normalizers::File.new

      success_message _("Report template updated.")
      failure_message _("Could not update the report template")

      build_options :without => [:template]
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Report template deleted.")
      failure_message _("Could not delete the report template")

      build_options
    end

    autoload_subcommands
  end

end
