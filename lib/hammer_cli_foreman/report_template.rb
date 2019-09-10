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
        field :default, _("Default"), Fields::Boolean
        HammerCLIForeman::References.timestamps(self)
        HammerCLIForeman::References.taxonomies(self)
        collection :inputs, _("Template inputs") do
          field :id, _("Id"), Fields::Id
          field :name, _('Name')
          field :description, _('Description')
          field :required, _("Required"), Fields::Boolean
          field :options, _('Options'), Fields::List, :hide_blank => true
        end
      end

      def extend_data(template)
        template[:inputs] = load_inputs
        template
      end

      build_options

      private

      def load_inputs
        template_inputs_api = HammerCLIForeman.foreman_api.resource(:template_inputs)
        params = {:template_id => options['option_id']}
        params[:organization_id] = options['option_organization_id'] if options['option_organization_id']
        params[:location_id] = options['option_location_id'] if options['option_locations_id']
        HammerCLIForeman.collection_to_common_format(template_inputs_api.call(:index, params))
      end
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

      option '--inputs', 'INPUTS', N_('Specify inputs'),
        :format => HammerCLI::Options::Normalizers::KeyValueList.new

      def default_filename
        "Report-#{Time.new.strftime("%Y-%m-%d")}.txt"
      end

      def request_params
        params = super
        params['input_values'] = option_inputs || {}
        params
      end

      build_options
    end

    class ScheduleCommand < HammerCLIForeman::Command
      command_name "schedule"
      action :schedule_report

      option '--inputs', 'INPUTS', N_('Specify inputs'),
        :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--wait', :flag, _('Turns a command to be active, wait for the result and download it right away')
      option '--path', "PATH", _("Path to directory where downloaded content will be saved. Only usable if wait is specified"),
        :attribute_name => :option_path

      def request_params
        params = super
        params['input_values'] = option_inputs || {}
        params
      end

      def transform_format(data)
        data
      end

      def execute
        data = send_request
        if option_wait?
          poll_for_report(data)
        else
          print_message(_('The report has been scheduled. Job ID: %{job_id}') % { job_id: data['job_id'] })
        end
        HammerCLI::EX_OK
      end

      build_options

      private

      def poll_for_report(schedule_data)
        report_data_args = build_report_data_args(schedule_data)
        report_command = ReportDataCommand.new(invocation_path, context)
        report_command.parse(report_data_args)
        begin
          response = report_command.send_request
        end while response && response.code == 204
        report_command.handle_success(response)
      end

      def build_report_data_args(schedule_data)
        [
          '--id', options['option_id'],
          '--job-id', schedule_data['job_id'],
          '--path', option_path
        ]
      end
    end

    class ReportDataCommand < HammerCLIForeman::DownloadCommand
      command_name "report-data"
      action :report_data

      def default_filename
        "Report-#{Time.new.strftime("%Y-%m-%d")}.txt"
      end

      build_options

      def execute
        response = send_request
        if response.code == 204
          print_message(_('The report is not ready yet.'))
          HammerCLI::EX_TEMPFAIL
        else
          handle_success(response)
          HammerCLI::EX_OK
        end
      end

      def handle_success(response)
        if option_path
          filepath = store_response(response)
          print_message(_('The response has been saved to %{path}.'), {:path => filepath})
        else
          puts response.body
        end
      end
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      option ['-i', '--interactive'], :flag, _('Open empty template in an $EDITOR. Upload the result')
      option "--file", "LAYOUT", _("Path to a file that contains the report template content"),
        :attribute_name => :option_template, :format => HammerCLI::Options::Normalizers::File.new

      validate_options do
        any(:option_interactive, :option_template).required
      end

      def request_params
        params = super
        if option_interactive?
          params['report_template']['template'] = HammerCLI.open_in_editor(
            '', content_type: 'report_template', suffix: '.erb')
        end
        params
      end

      success_message _("Report template created.")
      failure_message _("Could not create the report template")

      build_options :without => [:template]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      option ['-i', '--interactive'], :flag, _('Dump existing template and open it in an $EDITOR. Update with the result')
      option '--file', 'REPORT', _("Path to a file that contains the report template content"), :attribute_name => :option_template,
        :format => HammerCLI::Options::Normalizers::File.new

      def request_params
        params = super
        if option_interactive?
          template = load_template
          params['report_template']['template'] =  HammerCLI.open_in_editor(
            template['template'], content_type: 'report_template', suffix: '.erb')
        end
        params
      end

      success_message _("Report template updated.")
      failure_message _("Could not update the report template")

      build_options :without => [:template]

      private

      def load_template
        template_api = HammerCLIForeman.foreman_api.resource(:report_templates)
        params = {:id => options['option_id']}
        params[:organization_id] = options['option_organization_id'] if options['option_organization_id']
        params[:location_id] = options['option_location_id'] if options['option_locations_id']
        HammerCLIForeman.record_to_common_format(template_api.call(:show, params))
      end
    end

    class CloneCommand < HammerCLIForeman::UpdateCommand
      action :clone
      command_name 'clone'

      success_message _('Report template cloned.')
      failure_message _('Could not clone the report template')

      validate_options do
        option(:option_new_name).required
      end

      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Report template deleted.")
      failure_message _("Could not delete the report template")

      build_options
    end

    autoload_subcommands
  end

end
