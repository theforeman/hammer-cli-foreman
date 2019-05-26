module HammerCLIForeman
  module CommandExtensions
    class PuppetEnvironment < HammerCLI::CommandExtensions
      # Remove when support of --environment options is ended.
      option '--environment', 'ENVIRONMENT_NAME', _('Environment name'),
             attribute_name: :option_environment_name,
             deprecated: { '--environment' => _('Use --puppet-environment instead') }
      option '--environment-id', 'ENVIRONMENT_ID', _(''),
             format: HammerCLI::Options::Normalizers::Number.new,
             attribute_name: :option_environment_id,
             deprecated: { '--environment-id' => _('Use --puppet-environment-id instead') }

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
