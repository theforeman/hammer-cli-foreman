module HammerCLIForeman
  module CommandExtensions
    class PuppetEnvironment < HammerCLI::CommandExtensions
      # Remove when support of --environment options is ended.
      option_family(
        aliased_resource: 'environment',
        description: _('Puppet environment'),
        deprecation: _("Use %s instead") % '--puppet-environment[-id]',
        deprecated: { '--environment' => _("Use %s instead") % '--puppet-environment[-id]',
                      '--environment-id' => _("Use %s instead") % '--puppet-environment[-id]'}
      ) do
        parent '--environment-id', 'ENVIRONMENT_ID', _(''),
               format: HammerCLI::Options::Normalizers::Number.new,
               attribute_name: :option_environment_id
        child '--environment', 'ENVIRONMENT_NAME', _('Environment name'),
              attribute_name: :option_environment_name
      end

      option_sources do |sources, command|
        sources.find_by_name('IdResolution').insert_relative(
          :after,
          'IdParams',
          HammerCLIForeman::OptionSources::PuppetEnvironmentParams.new(command)
        )
        sources
      end
    end
  end
end
