module HammerCLIForeman
  module CommandExtensions
    class Fields < HammerCLI::CommandExtensions
      inheritable true

      use_option :fields

      option_sources do |sources, command|
        sources << HammerCLIForeman::OptionSources::FieldsParams.new(command)
      end
    end
  end
end
