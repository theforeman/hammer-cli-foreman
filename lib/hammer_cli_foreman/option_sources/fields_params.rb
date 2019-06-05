module HammerCLIForeman
  module OptionSources
    class FieldsParams < HammerCLI::Options::Sources::Base
      def initialize(command)
        @command = command
      end

      def process(defined_options, result)
        get_options(defined_options, result)
      end

      def get_options(_defined_options, result)
        if @command.respond_to?(:option_fields) && @command.option_fields == ['THIN']
          result[HammerCLI.option_accessor_name('thin')] = true
        end
        result
      end
    end
  end
end
