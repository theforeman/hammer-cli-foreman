module HammerCLIForeman

  class Template < HammerCLIForeman::Command

    resource :config_templates

    module TemplateCreateUpdateCommons

      def option_snippet
        option_type == "snippet"
      end

      def option_template_kind_id
        kinds = HammerCLIForeman.collection_to_common_format(
          HammerCLIForeman.foreman_resource!(:template_kinds).call(:index))
        table = kinds.inject({}){ |result, k| result.update(k["name"] => k["id"]) }
        table[option_type]
      end

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
        field :locked, _("Locked"), Fields::Boolean
        HammerCLIForeman::References.operating_systems(self)
        HammerCLIForeman::References.taxonomies(self)
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
      desc _("List available config template kinds.")

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
      desc _("View config template content.")

      def print_data(template)
        puts template["template"]
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--file", "TEMPLATE", _("Path to a file that contains the template"), :attribute_name => :option_template, :required => true,
        :format => HammerCLI::Options::Normalizers::File.new
      option "--type", "TYPE", _("Template type. Eg. snippet, script, provision"), :required => true

      success_message _("Config template created")
      failure_message _("Could not create the config template")

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

      success_message _("Config template updated")
      failure_message _("Could not update the config template")

      include TemplateCreateUpdateCommons

      build_options do |o|
        o.without(:template_combinations_attributes, :template, :snippet, :template_kind_id)
        o.expand.except(:template_kinds)
      end
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Config template deleted")
      failure_message _("Could not delete the config template")

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

      success_message _('Config template cloned')
      failure_message _('Could not clone the config template')

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

    HammerCLIForeman::AssociatingCommands::OperatingSystem.extend_command(self)

    autoload_subcommands
  end
end
