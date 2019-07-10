module HammerCLIForeman
  module CommandExtensions
    class PuppetEnvironments < HammerCLI::CommandExtensions
      # Remove when support of --environments options is ended.
      option '--environments', 'ENVIRONMENT_NAMES', _(''),
             attribute_name: :option_environment_names,
             deprecated: { '--environments' => _('Use --puppet-environments instead') }
      option '--environment-ids', 'ENVIRONMENT_IDS', _('Environment IDs'),
             format: HammerCLI::Options::Normalizers::List.new,
             attribute_name: :option_environment_ids,
             deprecated: { '--environment-ids' => _('Use --puppet-environment-ids instead') }

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
