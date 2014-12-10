module HammerCLIForeman

  class OperatingSystem < HammerCLIForeman::Command

    resource :operatingsystems

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :title, _("Title")
        field :release_name, _("Release name")
        field :family, _("Family")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :name, _("Name")
        field :major, _("Major version")
        field :minor, _("Minor version")
        collection :ptables, _("Partition tables"), :numbered => false do
          custom_field Fields::Reference
        end
        collection :os_default_templates, _("Default templates"), :numbered => false do
          custom_field Fields::Template, :id_key => :config_template_id, :name_key => :config_template_name
        end
        collection :architectures, _("Architectures"), :numbered => false do
          custom_field Fields::Reference
        end
        HammerCLIForeman::References.media(self)
        HammerCLIForeman::References.config_templates(self)
        HammerCLIForeman::References.parameters(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Operating system created")
      failure_message _("Could not create the operating system")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Operating system updated")
      failure_message _("Could not update the operating system")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Operating system deleted")
      failure_message _("Could not delete the operating system")

      build_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for an operating system.")

      success_message_for :update, _("Operating system parameter updated")
      success_message_for :create, _("New operating system parameter created")
      failure_message _("Could not set operating system parameter")

      def validate_options
        super
        validator.any(:option_operatingsystem_id, :option_operatingsystem_title).required
      end

      build_options
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for an operating system.")

      success_message _("operating system parameter deleted")

      def validate_options
        super
        validator.any(:option_operatingsystem_id, :option_operatingsystem_title).required
      end

      build_options
    end


    class SetOsDefaultTemplate < HammerCLIForeman::Command
      command_name "set-default-template"
      resource :os_default_templates

      option "--id", "OS ID", _("operatingsystem id"), :required => true, :referenced_resource => 'operatingsystem'
      option "--config-template-id", "TPL ID", _("config template id to be set"), :required => true


      success_message _("[%{config_template_name}] was set as default %{template_kind_name} template")
      failure_message _("Could not set the os default template")

      def option_type_name
        tpl = HammerCLIForeman.collection_to_common_format(
          HammerCLIForeman.foreman_resource!(:config_templates).call(:show, {"id" => option_config_template_id}))
        tpl[0]["template_kind_name"]
      end

      def base_action_params
        {"operatingsystem_id" => option_id}
      end

      def template_exist?(tpl_kind_name)
        templates = HammerCLIForeman.collection_to_common_format(resource.call(:index, base_action_params))
        templates.find { |p| p["template_kind_name"] == tpl_kind_name}
      end

      def update_default_template(tpl)
        params = {
          "id" => tpl["id"],
          "os_default_template" => {
            "config_template_id" => option_config_template_id,
            "template_kind_id" => tpl["template_kind_id"]
          }
        }.merge base_action_params

        HammerCLIForeman.record_to_common_format(resource.call(:update, params))
      end

      def create_default_template(tpl_kind_name)
        params = {
          "os_default_template" => {
            "config_template_id" => option_config_template_id,
            "template_kind_name" => tpl_kind_name
          }
        }.merge base_action_params

        HammerCLIForeman.record_to_common_format(resource.call(:create, params))
      end

      def execute
        tpl_kind_name = option_type_name
        tpl = template_exist? tpl_kind_name
        if tpl
          update_default_template tpl
          print_message(success_message, tpl) if success_message
        else
          tpl = create_default_template tpl_kind_name
          print_message(success_message, tpl) if success_message
        end
        HammerCLI::EX_OK
      end

      build_options :without => [:template_kind_id, :type]
    end


    class DeleteOsDefaultTemplate < HammerCLIForeman::Command
      command_name "delete-default-template"
      resource :os_default_templates

      option "--id", "OS ID", _("operatingsystem id"), :required => true, :referenced_resource => 'operatingsystem'
      option "--type", "TPL TYPE", _("Type of the config template"), :required => true

      success_message _("Default template deleted")
      failure_message _("Could not delete the default template")

      def execute
        templates = HammerCLIForeman.collection_to_common_format(resource.call(:index, base_action_params))
        tpl = templates.find { |p| p["template_kind_name"] == option_type }

        if tpl.nil?
          raise RuntimeError.new(_("Default template of type %s not found") % option_type)
        end

        params = {
          "id" => tpl["id"]
        }.merge base_action_params

        HammerCLIForeman.record_to_common_format(resource.call(:destroy, params))
        print_message success_message if success_message
        HammerCLI::EX_OK
      end

      def base_action_params
        {"operatingsystem_id" => option_id}
      end

      build_options
    end


    HammerCLIForeman::AssociatingCommands::Architecture.extend_command(self)
    HammerCLIForeman::AssociatingCommands::ConfigTemplate.extend_command(self)
    HammerCLIForeman::AssociatingCommands::PartitionTable.extend_command(self)


    autoload_subcommands
  end

end

