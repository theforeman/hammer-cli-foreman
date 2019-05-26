module HammerCLIForeman
  module OptionSources
    class PuppetEnvironmentParams < HammerCLI::Options::Sources::Base
      def initialize(command)
        @command = command
      end

      def get_options(_defined_options, result)
        if result['option_environment_id'].nil? &&
           (@command.respond_to?(:option_environment_id) ||
           @command.respond_to?(:option_environment_name))
          put_puppet_environment_id(result)
        end
        if result['option_environment_ids'].nil? &&
           (@command.respond_to?(:option_environment_ids) ||
           @command.respond_to?(:option_environment_names))
          put_puppet_environment_ids(result)
        end
        result
      end

      private

      def put_puppet_environment_id(result)
        if result['option_environment_name'].nil?
          if @command.option_environment_id
            result['option_environment_id'] = @command.option_environment_id
          elsif @command.option_environment_name
            result['option_environment_name'] = @command.option_environment_name
            result['option_environment_id'] = @command.resolver.puppet_environment_id(
              @command.resolver.scoped_options('environment', result, :single)
            )
          end
        else
          result['option_environment_id'] = @command.resolver.puppet_environment_id(
            @command.resolver.scoped_options('environment', result, :single)
          )
        end
      end

      def put_puppet_environment_ids(result)
        if result['option_environment_names'].nil?
          if @command.option_environment_ids
            result['option_environment_ids'] = @command.option_environment_ids
          elsif @command.option_environment_names
            result['option_environment_names'] = @command.option_environment_names
            result['option_environment_ids'] = @command.resolver.puppet_environment_ids(
              @command.resolver.scoped_options('environment', result, :multi)
            )
          end
        else
          result['option_environment_ids'] = @command.resolver.puppet_environment_ids(
            @command.resolver.scoped_options('environment', result, :multi)
          )
        end
      end
    end
  end
end
