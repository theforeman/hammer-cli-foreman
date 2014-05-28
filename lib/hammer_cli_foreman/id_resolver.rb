module HammerCLIForeman

  class Searchable

    def initialize(name, description, options={})
      @name = name
      @description = description
      @editable = options[:editable].nil? ? true : options[:editable]
    end

    attr_reader :name, :description

    def editable?
      @editable
    end

  end

  class Searchables

    SEARCHABLES = {
      :user => [ Searchable.new("login", _("User's login to search by")) ],
      :template => [],
      :image => [],
      :operatingsystem => []
    }
    DEFAULT_SEARCHABLES = [ Searchable.new("name", _("Name to search by")) ]

    def for(resource)
      SEARCHABLES[resource.singular_name.to_sym] || DEFAULT_SEARCHABLES
    end

  end

  class IdResolver

    attr_reader :api

    def initialize(api, searchables)
      @api = api
      @searchables = searchables
      define_id_finders
    end

    def scoped_options(scope, options)
      scoped_options = options.dup

      resource = param_to_resource(scope)
      return scoped_options unless resource

      option_names = searchables(resource).map { |s| s.name }
      option_names << "id"

      option_names.each do |name|
        option = HammerCLI.option_accessor_name(name)
        scoped_option = HammerCLI.option_accessor_name("#{scope}_#{name}")
        # remove the scope
        # e.g. option_architecture_id -> option_id
        if scoped_options[scoped_option]
          scoped_options[option] = scoped_options.delete(scoped_option)
        else
          scoped_options.delete(option)
        end
      end
      scoped_options
    end

    def dependent_resources(resource, options={})
      options[:required] = (options[:required] == true)
      options[:recursive] = !(options[:recursive] == false)

      resolve_dependent_resources(resource, [], options)
    end

    def id_params(action, options={})
      required = !(options[:required] == false)

      params = action.params.reject{ |p| !(p.name.end_with?("_id")) }
      params = params.reject{ |p| !(p.required?) } if required
      params
    end

    def param_to_resource(param_name)
      resource_name = param_name.gsub(/_id$/, "")
      resource_name = ApipieBindings::Inflector.pluralize(resource_name.to_s).to_sym
      begin
        @api.resource(resource_name)
      rescue NameError
        nil
      end
    end

    protected

    def resolve_dependent_resources(resource, resources_found, options)
      id_params(resource.action(:index), :required => options[:required]).each do |param|
        res = param_to_resource(param.name)
        if res and !resources_found.map(&:name).include?(res.name)
          resources_found << res
          resolve_dependent_resources(res, resources_found, options) if options[:recursive]
        end
      end
      resources_found
    end

    def define_id_finders
      @api.resources.each do |resource|
        method_name = "#{resource.singular_name}_id"

        self.class.send(:define_method, method_name) do |options|
          get_id(resource.name, options)
        end unless respond_to?(method_name)
      end
    end

    def get_id(resource_name, options)
      options[HammerCLI.option_accessor_name("id")] || find_resource(resource_name, options)['id']
    end

    def find_resource(resource_name, options)
      resource = @api.resource(resource_name)

      search_options = search_options(options, resource)
      id_params(resource.action(:index), :required => true).each do |param|
        search_options[param.name] ||= send(param.name, scoped_options(param.name.gsub(/_id$/, ""), options))
      end
      resource.action(:index).routes.each do |route|
        route.params_in_path.each do |param|
          key = HammerCLI.option_accessor_name(param.to_s)
          if options[key]
            search_options[param] ||= options[key]
          end
        end
      end

      results = resource.call(:index, search_options)
      results = HammerCLIForeman.collection_to_common_format(results)

      pick_result(results, resource)
    end

    def pick_result(results, resource)
      raise ResolverError.new(_("%s not found") % resource.singular_name) if results.empty?
      raise ResolverError.new(_("%s found more than once") % resource.singular_name) if results.count > 1
      results[0]
    end

    def search_options(options, resource)
      search_options = create_search_options(options, resource)
      raise MissingSeachOptions.new(_("Missing options to search %s") % resource.singular_name) if search_options.empty?
      search_options
    end

    def searchables(resource)
      @searchables.for(resource)
    end

    def create_search_options(options, resource)
      searchables(resource).each do |s|
        value = options[HammerCLI.option_accessor_name(s.name.to_s)]
        if value
          return {:search => "#{s.name} = \"#{value}\""}
        end
      end
      {}
    end

  end

end
