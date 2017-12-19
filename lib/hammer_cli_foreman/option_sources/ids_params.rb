module HammerCLIForeman
  module OptionSources
    class IdsParams
      def initialize(command)
        @command = command
      end

      def get_options(defined_options, result)
        return result if @command.action.nil?
        # resolve all '<resource_name>_ids' parameters if they are defined as options
        IdArrayParamsFilter.new(:only_required => false).for_action(@command.resource.action(@command.action)).each do |api_param|
          param_resource = HammerCLIForeman.param_to_resource(api_param.name)
          if param_resource && @command.respond_to?(HammerCLI.option_accessor_name("#{param_resource.singular_name}_ids"))
            resource_ids = @command.get_resource_ids(param_resource, :scoped => true, :required => api_param.required?, :all_options => result)
            result[HammerCLI.option_accessor_name(api_param.name)] = resource_ids if resource_ids
          end
        end
        result
      end
    end
  end
end
