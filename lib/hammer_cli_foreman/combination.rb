module HammerCLIForeman
  class Combination < HammerCLIForeman::Command
    resource :template_combinations
    command_name 'combination'
    desc _("Manage template combinations")

    module RequestParams
      def request_params
        combination_params = { 'hostgroup_id' => params['hostgroup_id'].to_s,
                               'environment_id' => params['environment_id'].to_s }
        super.merge('template_combination' => combination_params)
      end
    end


    class InfoCombination < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :id, _('ID')
        field :provisioning_template_id, _('Provisioning template ID')
        field :provisioning_template_name, _('Provisioning template name')
        field :hostgroup_id, _('Hostgroup ID')
        field :hostgroup_name, _('Hostgroup name')
        field :environment_id, _('Environment ID')
        field :environment_name, _('Environment name')

        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)

      end
      build_options do |o|
        o.expand(:all)
      end

      extend_with(HammerCLIForeman::CommandExtensions::PuppetEnvironment.new)
    end

    class ListCombination < HammerCLIForeman::ListCommand
      output do
        field :id, _('ID')
        field nil, _('Provisioning Template'), Fields::SingleReference, :key => :provisioning_template
        field nil, _('Hostgroup'), Fields::SingleReference, :key => :hostgroup
        field nil, _('Environment'), Fields::SingleReference, :key => :environment
      end

      build_options do |o|
        o.expand(:all).except(:hostgroups, :environments)
        o.without(:hostgroup_id, :environment_id)
      end
    end

    class UpdateCombination < HammerCLIForeman::UpdateCommand
      extend RequestParams

      success_message _("Template combination updated.")
      failure_message _("Could not update the template combination")

      build_options do |o|
        o.expand(:all)
      end

      extend_with(HammerCLIForeman::CommandExtensions::PuppetEnvironment.new)
    end

    class CreateCombination < HammerCLIForeman::CreateCommand
      extend RequestParams

      success_message _("Template combination created.")
      failure_message _("Could not create the template combination")

      build_options do |o|
        o.expand(:all)
      end

      extend_with(HammerCLIForeman::CommandExtensions::PuppetEnvironment.new)
    end

    class DeleteCombination < HammerCLIForeman::DeleteCommand

      success_message _("Template combination Deleted.")
      failure_message _("Could not delete the template combination")

      build_options
    end

    autoload_subcommands
  end
end
