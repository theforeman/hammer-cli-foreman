module HammerCLIForeman

  class Template < HammerCLIForeman::Command

    resource :provisioning_templates

    module TemplateCreateUpdateCommons
      def option_snippet
        option_type && (option_type == "snippet")
      end

      # This method is for IdParams option source to make resolver work for
      # --type option
      def option_template_kind_id; end
    end

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :type, _("Type")
      end

      def extend_data(tpl)
        if tpl["snippet"]
          tpl["type"] = "snippet"
        elsif tpl["template_kind"]
          tpl["type"] = tpl["template_kind"]["name"]
        else
          tpl["type"] = tpl["template_kind_name"]
        end
        tpl
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :description, _('Description'), Fields::Text
        field :locked, _("Locked"), Fields::Boolean
        field :cloned_from_id, _("Cloned from id"), nil, :hide_blank => true
        HammerCLIForeman::References.operating_systems(self)
        HammerCLIForeman::References.taxonomies(self)
        collection :template_combinations, 'Template Combinations' do
          field :hostgroup_name, _('Hostgroup name')
          field :environment_name, _('Environment name')
        end
      end

      def extend_data(tpl)
        if tpl["snippet"]
          tpl["type"] = "snippet"
        elsif tpl["template_kind"]
          tpl["type"] = tpl["template_kind"]["name"]
        else
          tpl["type"] = tpl["template_kind_name"]
        end
        tpl['operatingsystem_ids'] = tpl['operatingsystems'].map { |os| os['id'] } rescue []
        tpl
      end

      build_options
    end


    class ListKindsCommand < HammerCLIForeman::ListCommand

      command_name "kinds"
      desc _("List available provisioning template kinds")

      output do
        field :name, _("Name")
      end

      def send_request
        kinds = super
        kinds << { "name" => "snippet" }
        kinds
      end

      resource :template_kinds, :index
    end


    class DumpCommand < HammerCLIForeman::InfoCommand

      command_name "dump"
      desc _("View provisioning template content")

      def print_data(template)
        puts template["template"]
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--file", "TEMPLATE", _("Path to a file that contains the template"), :attribute_name => :option_template, :required => true,
        :format => HammerCLI::Options::Normalizers::File.new
      option "--type", "TYPE", _("Template type. Eg. snippet, script, provision"), :required => true

      success_message _("Provisioning template created.")
      failure_message _("Could not create the provisioning template")

      include TemplateCreateUpdateCommons

      build_options do |o|
        o.without(:template_combinations_attributes, :template, :snippet, :template_kind_id)
        o.expand.except(:template_kinds)
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      option "--file", "TEMPLATE", _("Path to a file that contains the template"), :attribute_name => :option_template,
        :format => HammerCLI::Options::Normalizers::File.new
      option "--type", "TYPE", _("Template type. Eg. snippet, script, provision")

      success_message _("Provisioning template updated.")
      failure_message _("Could not update the provisioning template")

      include TemplateCreateUpdateCommons

      build_options do |o|
        o.without(:template_combinations_attributes, :template, :snippet, :template_kind_id)
        o.expand.except(:template_kinds)
      end
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Provisioning template deleted.")
      failure_message _("Could not delete the provisioning template")

      build_options
    end

    class ImportCommand < HammerCLIForeman::Command
      command_name "import"
      action :import
      option '--file', 'PATH', _('Path to a file that contains the template content including metadata'),
             :attribute_name => :option_template, :format => HammerCLI::Options::Normalizers::File.new

      validate_options do
        all(:option_name, :option_template).required
      end

      success_message _("Import provisioning template succeeded.")
      failure_message _("Could not import provisioning template")

      build_options :without => [:template]
    end

    class ExportCommand < HammerCLIForeman::DownloadCommand
      command_name "export"
      action :export

      def default_filename
        "Template-#{Time.new.strftime("%Y-%m-%d")}.txt"
      end

      def saved_response_message(filepath)
        _("The provisioning template has been saved to %{path}.") % { path: filepath }
      end

      build_options
    end
    
    class BuildPXEDefaultCommand < HammerCLIForeman::Command

      action :build_pxe_default

      command_name "build-pxe-default"
      desc _("Update the default PXE menu on all configured TFTP servers")

      def print_data(message)
        puts message
      end

      build_options
    end

    class CloneCommand < HammerCLIForeman::SingleResourceCommand
      action :clone
      command_name 'clone'

      success_message _('Provisioning template cloned.')
      failure_message _('Could not clone the provisioning template')

      validate_options do
        option(:option_new_name).required
      end

      def self.create_option_builder
        builder = super
        builder.builders << SearchablesUpdateOptionBuilder.new(resource, searchables) if resource_defined?
        builder
      end

      def method_options_for_params(params, include_nil = true)
        opts = super
        # overwrite searchables with correct values
        searchables.for(resource).each do |s|
          new_value = get_option_value("new_#{s.name}")
          opts[s.name] = new_value unless new_value.nil?
        end
        opts
      end

      build_options
    end

    lazy_subcommand('combination', _("Manage template combinations"),
                    'HammerCLIForeman::Combination', 'hammer_cli_foreman/combination'
    )

    HammerCLIForeman::AssociatingCommands::OperatingSystem.extend_command(self)

    autoload_subcommands
  end
end
