module HammerCLIForeman
  module OptionSources
    class IdsParams < HammerCLI::Options::Sources::Base
      def initialize(command)
        @command = command
      end

      def param_updatable?(param_resource)
        param_resource && @command.respond_to?(cli_option_resource_ids(param_resource))
      end

      def available_ids_params
        IdArrayParamsFilter.new(:only_required => false).for_action(@command.resource.action(@command.action))
      end

      def needs_resolving?(param_option, param_resource, all_opts)
        return false unless param_updatable?(param_resource)

        cli_searchables_set = @command.searchables.for(param_resource).any? do |s|
          option = HammerCLI.option_accessor_name("#{param_resource.singular_name}_#{s.plural_name}")
          next false unless @command.respond_to?(option)

          !@command.send(option).nil?
        end
        if cli_searchables_set
          # Remove set '<resource_name>_ids' option to force resolving in case of
          # '<resource_name>_[names|titles]' were set from CLI
          all_opts.delete(param_option)
          true
        else
          # Don't resolve if resource ids were set via CLI
          return false if @command.send(cli_option_resource_ids(param_resource))

          all_opts[param_option].nil?
        end
      end

      def get_options(_defined_options, result)
        # resolve all '<resource_name>_ids' parameters if they are defined as options
        return result if @command.action.nil?

        available_ids_params.each do |api_param|
          param_resource = HammerCLIForeman.param_to_resource(api_param.name)
          param_option = HammerCLI.option_accessor_name(api_param.name)
          next unless needs_resolving?(param_option, param_resource, result)

          resource_ids = @command.get_resource_ids(
            param_resource, scoped: true, required: api_param.required?, all_options: result
          )
          result[param_option] = resource_ids if resource_ids
        end
        result
      end

      private

      def cli_option_resource_ids(resource)
        HammerCLI.option_accessor_name("#{resource.singular_name}_ids")
      end
    end
  end
end
