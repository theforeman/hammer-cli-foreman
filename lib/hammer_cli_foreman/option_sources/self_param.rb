module HammerCLIForeman
  module OptionSources
    class SelfParam
      def initialize(command)
        @command = command
      end

      def get_options(defined_options, result)
        # resolve 'id' parameter if it's defined as an option
        id_option_name = HammerCLI.option_accessor_name('id')
        result[id_option_name] ||= @command.get_identifier(result) if @command.respond_to?(id_option_name)
        result
      end
    end
  end
end
