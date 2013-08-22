require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class Template < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand

      heading "Template list"
      output do
        from "config_template" do
          field :id, "Id"
          field :name, "Name"
          field :type, "Type"
        end
      end

      def retrieve_data
        templates = super
        templates.each do |tpl|
          if tpl["config_template"]["snippet"]
            tpl["config_template"]["type"] = "snippet"
          else
            tpl["config_template"]["type"] = tpl["config_template"]["template_kind"]["name"]
          end
        end
      end

      resource ForemanApi::Resources::ConfigTemplate, "index"
      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      #FIXME: Add name identifier when the find by name issue is fixed in the api
      #       Api currently does not accept names containing a dot
      identifiers :id

      heading "Template info"
      output ListCommand.output_definition do
        from "config_template" do
          field :operatingsystem_ids, "OS ids", HammerCLI::Output::Fields::List
        end
      end

      def retrieve_data
        template = super
        if template["config_template"]["snippet"]
          template["config_template"]["type"] = "snippet"
        else
          template["config_template"]["type"] = template["config_template"]["template_kind"]["name"]
        end
        template
      end

      resource ForemanApi::Resources::ConfigTemplate, "show"
    end


    class ListKindsCommand < HammerCLIForeman::ListCommand

      heading "Template kind list"
      output do
        from "template_kind" do
          field :name, "Name"
        end
      end

      def retrieve_data
        snippet = { "template_kind" => { "name" => "snippet" }}
        super << snippet
      end

      resource ForemanApi::Resources::TemplateKind, "index"
    end


    class DumpCommand < HammerCLIForeman::InfoCommand

      identifiers :id

      resource ForemanApi::Resources::ConfigTemplate, "show"

      def print_data(template)
        puts template["config_template"]["template"]
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--file", "TEMPLATE", "Path to a file that contains the template", :attribute_name => :template, :required => true, &HammerCLI::OptionFormatters.method(:file)
      option "--type", "TYPE", "Template type. Eg. snippet, script, provision", :required => true

      success_message "Config template created"
      failure_message "Could not create the config template"
      resource ForemanApi::Resources::ConfigTemplate, "create"

      def snippet
        type == "snippet"
      end

      def template_kind_id
        kinds = ForemanApi::Resources::TemplateKind.new(resource_config).index()[0]
        table = kinds.inject({}){ |result, k| result.update(k["template_kind"]["name"] => k["template_kind"]["id"]) }
        table[type]
      end

      apipie_options :without => [:template_combinations_attributes, :template, :snippet, :template_kind_id]
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      option "--file", "TEMPLATE", "Path to a file that contains the template", :attribute_name => :template, &HammerCLI::OptionFormatters.method(:file)
      option "--type", "TYPE", "Template type. Eg. snippet, script, provision"

      identifiers :id

      success_message "Config template updated"
      failure_message "Could not update the config template"
      resource ForemanApi::Resources::ConfigTemplate, "update"

      def snippet
        type == "snippet"
      end

      def template_kind_id
        kinds = ForemanApi::Resources::TemplateKind.new(resource_config).index()[0]
        table = kinds.inject({}){ |result, k| result.update(k["template_kind"]["name"] => k["template_kind"]["id"]) }
        table[type]
      end

      apipie_options :without => [:template_combinations_attributes, :template, :snippet, :template_kind_id]
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id

      success_message "Config template deleted"
      failure_message "Could not delete the config template"
      resource ForemanApi::Resources::ConfigTemplate, "destroy"
    end

    subcommand "list", "List config templates.", HammerCLIForeman::Template::ListCommand
    subcommand "info", "Detailed info about a config template.", HammerCLIForeman::Template::InfoCommand
    subcommand "dump", "View config template content.", HammerCLIForeman::Template::DumpCommand
    subcommand "create", "Create a new config template.", HammerCLIForeman::Template::CreateCommand
    subcommand "update", "Update a config template.", HammerCLIForeman::Template::UpdateCommand
    subcommand "delete", "Delete a config template.", HammerCLIForeman::Template::DeleteCommand
    subcommand "kinds", "List available config template kinds.", HammerCLIForeman::Template::ListKindsCommand

  end

end

HammerCLI::MainCommand.subcommand 'template', "Manipulate Foreman's config templates.", HammerCLIForeman::Template

