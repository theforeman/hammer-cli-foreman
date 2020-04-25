module HammerCLIForeman
  module CommandExtensions
    class PuppetEnvironments < HammerCLI::CommandExtensions
      # Remove when support of --environments options is ended.
      option_family(
        aliased_resource: 'environment',
        description: _('Puppet environments'),
        deprecation: _("Use %s instead") % '--puppet-environment[s|-ids]',
        deprecated: { '--environments' => _("Use %s instead") % '--puppet-environment[s|-ids]',
                      '--environment-ids' => _("Use %s instead") % '--puppet-environment[s|-ids]' }
      ) do
        parent '--environment-ids', 'ENVIRONMENT_IDS', _('Environment IDs'),
               format: HammerCLI::Options::Normalizers::List.new,
               attribute_name: :option_environment_ids
        child '--environments', 'ENVIRONMENT_NAMES', _(''),
              attribute_name: :option_environment_names
      end

      option_sources do |sources, command|
        sources.find_by_name('IdResolution').insert_relative(
          :after,
          'IdsParams',
          HammerCLIForeman::OptionSources::PuppetEnvironmentParams.new(command)
        )
        sources
      end
    end
  end
end
