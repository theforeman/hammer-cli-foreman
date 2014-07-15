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

    protected

    def self.s(name, description, options={})
      Searchable.new(name, description, options)
    end

    def self.s_name(description, options={})
      s("name", description, options)
    end

    SEARCHABLES = {
      :architecture =>     [ s_name(_("Architecture name")) ],
      :compute_resource => [ s_name(_("Compute resource name")) ],
      :domain =>           [ s_name(_("Domain name")) ],
      :environment =>      [ s_name(_("Environment name")) ],
      :fact_value =>       [],
      :filter =>           [],
      :host =>             [ s_name(_("Host name")) ],
      :hostgroup =>        [ s_name(_("Hostgroup name")) ],
      :image =>            [],
      :location =>         [ s_name(_("Location name")) ],
      :medium =>           [ s_name(_("Medium name")) ],
      :model =>            [ s_name(_("Model name")) ],
      :organization =>     [ s_name(_("Organization name")) ],
      :operatingsystem =>  [],
      :ptable =>           [ s_name(_("Partition table name")) ],
      :proxy =>            [ s_name(_("Proxy name")) ],
      :puppetclass =>      [ s_name(_("Puppet class name")) ],
      :report =>           [ s_name(_("Report name")) ],
      :role =>             [ s_name(_("User role name")) ],
      :subnet =>           [ s_name(_("Subnet name")) ],
      :template =>         [],
      :user =>             [ s("login", _("User's login to search by")) ],
      :common_parameter =>      [ s_name(_("Common parameter name")) ],
      :smart_class_parameter => [ s_name(_("Smart class parameter name")) ]
    }
    DEFAULT_SEARCHABLES = [ s_name(_("Name to search by")) ]

    public

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

      resource = HammerCLIForeman.param_to_resource(scope)
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


    protected

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
      IdParamsFilter.new(:only_required => true).for_action(resource.action(:index)).each do |param|
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
      method = "create_#{resource.name}_search_options"
      search_options = if respond_to?(method)
                         send(method, options)
                       else
                         create_search_options(options, resource)
                       end
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
