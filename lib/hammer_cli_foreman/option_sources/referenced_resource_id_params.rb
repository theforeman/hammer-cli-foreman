module HammerCLIForeman
  module OptionSources
    class ReferencedResourceIdParams < HammerCLIForeman::OptionSources::IdParams
      def param_updatable?(resource, api_param)
        resource && @command.respond_to?(HammerCLI.option_accessor_name(api_param.name))
      end

      def get_options(defined_options, result)
        return result if @command.action.nil?

        available_id_params.each do |api_param|
          attr_name = HammerCLI.option_accessor_name(api_param.name.gsub('_id', '_name'))
          option = @command.class.find_options(attribute_name: attr_name).first
          next unless option

          resource = HammerCLIForeman.foreman_resource(option.referenced_resource, singular: true)
          if result[HammerCLI.option_accessor_name(api_param.name)].nil? && param_updatable?(resource, api_param)
            scope = { HammerCLI.option_accessor_name("#{resource.singular_name}_name") => result[attr_name] }
            resource_id = @command.get_resource_id(
              resource, scoped: true, required: api_param.required?,
              all_options: result.merge(scope))
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
