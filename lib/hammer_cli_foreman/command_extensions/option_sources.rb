module HammerCLIForeman
  module CommandExtensions
    class OptionSources < HammerCLI::CommandExtensions
      inheritable true

      option_sources do |sources, command|
        id_resolution = HammerCLI::Options::ProcessorList.new(name: 'IdResolution')
        id_resolution << HammerCLIForeman::OptionSources::IdParams.new(command)
        id_resolution << HammerCLIForeman::OptionSources::IdsParams.new(command)
        id_resolution << HammerCLIForeman::OptionSources::SelfParam.new(command)

        sources << id_resolution
      end
    end
  end
end
