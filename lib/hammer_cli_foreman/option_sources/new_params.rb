module HammerCLIForeman
  module OptionSources
    class NewParams < HammerCLI::Options::Sources::Base
      def initialize(command)
        @command = command
      end

      def get_options(_defined_options, result)
        resource_names = @command.class.option_builder.builders
                                 .select { |b| b.class == HammerCLIForeman::UpdateDependentSearchablesOptionBuilder }
                                 .collect(&:resource)
                                 .collect(&:singular_name)
        new_result = resource_names.each_with_object({}) do |name, results|
          new_name = @command.send("option_new_#{name}_name") || @command.send("option_new_#{name}_title")
          results["option_new_#{name}_id"] =
            if new_name
              @command.resolver.send("#{name}_id", 'option_name' => new_name)
            else
              @command.send("option_new_#{name}_id")
            end
        end
        result.merge!(new_result)
      end
    end
  end
end
