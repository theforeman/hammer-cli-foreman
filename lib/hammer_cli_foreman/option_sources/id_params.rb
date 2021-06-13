module HammerCLIForeman
  module OptionSources
    class IdParams < HammerCLI::Options::Sources::Base
      def initialize(command)
        @command = command
      end

      def param_updatable?(param_resource)
        param_resource && @command.respond_to?(HammerCLI.option_accessor_name("#{param_resource.singular_name}_id"))
      end

      def available_id_params
        IdParamsFilter.new(:only_required => false).for_action(@command.resource.action(@command.action))
      end

      def needs_resolving?(param_option, param_resource, all_opts)
        return false unless param_updatable?(param_resource)

        searchables_set = @command.searchables.for(param_resource).any? do |s|
          option = HammerCLI.option_accessor_name("#{param_resource.singular_name}_#{s.name}")
          !all_opts[option].nil?
        end
        return all_opts[param_option].nil? unless searchables_set

        # Remove set '<resource_name>_id' option to force resolving in case of
        # '<resource_name>_[name|title]' was set
        all_opts.delete(param_option)
        true
      end

      def get_options(_defined_options, result)
        # resolve all '<resource_name>_id' parameters if they are defined as options
        # (they can be skipped using .without or .expand.except)
        return result if @command.action.nil?

        available_id_params.each do |api_param|
          param_resource = HammerCLIForeman.param_to_resource(api_param.name)
          param_option = HammerCLI.option_accessor_name(api_param.name)
          next unless needs_resolving?(param_option, param_resource, result)

          resource_id = @command.get_resource_id(
            param_resource, scoped: true, required: api_param.required?, all_options: result
          )
          result[param_option] = resource_id if resource_id
        end
        result
      rescue HammerCLIForeman::MissingSearchOptions => e
        switches = @command.class.find_options(referenced_resource: e.resource.singular_name).map(&:long_switch)

        if switches.empty?
          error_message = _("Could not find %{resource}. Some search options were missing, please see --help.")
        elsif switches.length == 1
          error_message = _("Could not find %{resource}, please set option %{switches}.")
        else
          error_message = _("Could not find %{resource}, please set one of options %{switches}.")
        end

        raise MissingSearchOptions.new(
          error_message % {
            resource: e.resource.singular_name,
            switches: switches.join(', ')
          },
          e.resource
        )
      end
    end
  end
end
