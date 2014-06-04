module HammerCLIForeman


  class DependencyResolver

    def action_dependencies(action, options={})
      options[:only_required] = (options[:only_required] == true)
      options[:recursive] = !(options[:recursive] == false)

      resolve_for_action(action, [], options)
    end

    def resource_dependencies(resource, options={})
      action_dependencies(resource.action(:index), options)
    end

    protected

    def resolve_for_action(action, resources_found, options)
      IdParamsFilter.new.for_action(action, :only_required => options[:only_required]).each do |param|
        res = HammerCLIForeman.param_to_resource(param.name)
        if res and !resources_found.map(&:name).include?(res.name)
          resources_found << res
          resolve_for_action(res.action(:index), resources_found, options) if options[:recursive]
        end
      end
      resources_found
    end

  end

end
