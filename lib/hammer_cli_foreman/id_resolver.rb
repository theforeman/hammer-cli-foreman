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

    def initialize(api, searchables)
      @api = api
      @searchables = searchables
      define_id_finders
    end

    def scoped_options(scope, options)
      prefix = HammerCLI.option_accessor_name("#{scope}_")
      plain_prefix = HammerCLI.option_accessor_name("")

      scoped_options = options.dup
      options.each do |k, v|
        if k.start_with? prefix
          # remove the scope
          # e.g. option_architecture_id -> option_id
          scoped_options[k.sub(prefix, plain_prefix)] = v
          scoped_options.delete(k)
        end
      end
      scoped_options
    end

    def dependent_resources(resource)
      resources = []
      required_params(resource.action(:index)).each do |param_name|
        if param_name.end_with?("_id")
          res = @api.resource(param_to_resource(param_name))
          resources << res
          resources += dependent_resources(res)
        end
      end
      resources
    end

    protected

    def define_id_finders
      @api.resources.each do |resource|
        method_name = "#{resource.singular_name}_id"

        self.class.send(:define_method, method_name) do |options|
          get_id(resource.name, options)
        end unless respond_to?(method_name)
      end
    end

    def param_to_resource(param_name)
      resource_name = param_name.gsub(/_id$/, "")
      resource_name = ApipieBindings::Inflector.pluralize(resource_name.to_s).to_sym
      resource_name
    end

    def get_id(resource_name, options)
      options[HammerCLI.option_accessor_name("id")] || find_resource(resource_name, options)['id']
    end

    def find_resource(resource_name, options)
      resource = @api.resource(resource_name)

      search_options = search_options(options, resource)
      required_params(resource.action(:index)).each do |param|
        search_options[param] ||= send(param, scoped_options(param.gsub(/_id$/, ""), options))
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

      raise _("%s not found") % resource.singular_name if results.empty?
      raise _("%s found more than once") % resource.singular_name if results.count > 1
      results[0]
    end

    def required_params(action)
      action.params.reject{ |p| !p.required? }.map(&:name)
    end

    def search_options(options, resource)
      search_options = create_search_options(options, resource)
      raise _("Missing options to search %s") % resource.singular_name if search_options.empty?
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
