module HammerCLIForeman
  module OptionSources
    class IdParams
      def initialize(command)
        @command = command
      end

      def get_options(defined_options, result)
        # resolve all '<resource_name>_id' parameters if they are defined as options
        # (they can be skipped using .without or .expand.except)
        return result if @command.action.nil?
        IdParamsFilter.new(:only_required => false).for_action(@command.resource.action(@command.action)).each do |api_param|
          param_resource = HammerCLIForeman.param_to_resource(api_param.name)
          if param_resource && @command.respond_to?(HammerCLI.option_accessor_name("#{param_resource.singular_name}_id"))
            resource_id = @command.get_resource_id(param_resource, :scoped => true, :required => api_param.required?, :all_options => result)
            result[HammerCLI.option_accessor_name(api_param.name)] = resource_id if resource_id
          end
        end
        result

      rescue HammerCLIForeman::MissingSearchOptions => e

        switches = @command.class.find_options(:referenced_resource => e.resource.singular_name).map(&:long_switch)

        if switches.empty?
          error_message = _("Could not find %{resource}. Some search options were missing, please see --help.")
        elsif switches.length == 1
          error_message = _("Could not find %{resource}, please set option %{switches}.")
        else
          error_message = _("Could not find %{resource}, please set one of options %{switches}.")
        end

        raise MissingSearchOptions.new(
          error_message % {
            :resource => e.resource.singular_name,
            :switches => switches.join(", ")
          },
          e.resource
        )
      end
    end
  end
end
