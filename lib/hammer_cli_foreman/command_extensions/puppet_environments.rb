module HammerCLIForeman
  module CommandExtensions
    class PuppetEnvironments < HammerCLI::CommandExtensions
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
