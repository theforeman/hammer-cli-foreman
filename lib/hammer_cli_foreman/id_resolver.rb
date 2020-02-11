module HammerCLIForeman

  class Searchable

    def initialize(name, description, options={})
      @name = name
      @description = description
      @editable = options[:editable].nil? ? true : options[:editable]
      @format = options[:format]
    end

    attr_reader :name, :description

    def plural_name
      ApipieBindings::Inflector.pluralize(@name)
    end

    def editable?
      @editable
    end

    def format
      @format
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
      :audit =>            [],
      :compute_resource => [ s_name(_("Compute resource name")) ],
      :compute_profile => [ s_name(_("Compute profile name")) ],
      :domain =>           [ s_name(_("Domain name")) ],
      :environment =>        [s_name(_('Puppet environment name'))],
      :puppet_environment => [s_name(_('Puppet environment name'))],
      :fact_value =>       [],
      :filter =>           [],
      :host =>             [ s_name(_("Host name")) ],
      :hostgroup =>        [ s_name(_("Hostgroup name")), s("title", _("Hostgroup title"), :editable => false) ],
      # :image =>            [],
      :interface =>        [],
      :location =>         [  s("name", _("Location Name, Set the current location context for the request")),
                              s("title", _("Location title, Set the current location context for the request" ),:editable => false),
                              s("id", _("Set the current location context for the request"), :editable => false, :format => HammerCLI::Options::Normalizers::Number.new),
      ],
      :medium =>           [ s_name(_("Medium name")) ],
      :model =>            [ s_name(_("Model name")) ],
      :organization =>     [ s("name", _("Set the current organization context for the request")),
                             s("title", _("Set the current organization context for the request"),:editable => false),
                             s("id", _("Set the current organization context for the request"), :editable => false, :format => HammerCLI::Options::Normalizers::Number.new),
      ],
      :operatingsystem =>  [ s("title", _("Operating system title"), :editable => false) ],
      :override_value =>   [],
      :ptable =>           [ s_name(_("Partition table name")) ],
      :proxy =>            [ s_name(_("Proxy name")) ],
      :puppetclass =>      [ s_name(_("Puppet class name")) ],
      :config_report =>    [],
      :role =>             [ s_name(_("User role name")) ],
      :setting =>          [ s_name(_("Setting name"), :editable => false) ],
      :subnet =>           [ s_name(_("Subnet name")) ],
      :template =>         [],
      :user =>             [ s("login", _("User's login to search by")) ],
      :common_parameter =>      [ s_name(_("Common parameter name")) ],
      :smart_class_parameter => [ s_name(_("Smart class parameter name"), :editable => false) ],
      :template_combination => [],
      :compute_attribute => []
    }
    DEFAULT_SEARCHABLES = [ s_name(_("Name to search by")) ]

    public

    def for(resource)
      SEARCHABLES[resource.singular_name.to_sym] || DEFAULT_SEARCHABLES
    end

  end

  class IdResolver
    ALL_PER_PAGE = 1000

    attr_reader :api

    def initialize(api, searchables)
      @api = api
      @searchables = searchables
      define_id_finders
    end

    # @param mode [Symbol] mode in which ids are searched :single, :multi, nil for old beahvior
    def scoped_options(scope, options, mode = nil)
      scoped_options = options.dup

      resource = HammerCLIForeman.param_to_resource(scope)
      return scoped_options unless resource

      option_names = []
      if (mode.nil? || mode == :single)
        option_names += searchables(resource).map { |s| s.name }
        option_names << "id" unless option_names.include?("id")
      end
      if (mode.nil? || mode == :multi)
        option_names << "ids"
        option_names += searchables(resource).map { |s| s.plural_name }
      end
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

    def puppetclass_ids(options)
      resource_name = :puppetclasses
      resource = @api.resource(resource_name)
      results = if (ids = options[HammerCLI.option_accessor_name("ids")])
        ids
      elsif (ids = nil_from_searchables(resource_name, options, :plural => true))
        ids
      elsif options_not_set?(resource, options)
        raise MissingSearchOptions.new(_("Missing options to search %s") % resource.name, resource)
      elsif options_empty?(resource, options)
        []
      else
        require('hammer_cli_foreman/puppet_class')
        results = HammerCLIForeman::PuppetClass::ListCommand.unhash_classes(
          resolved_call(resource_name, :index, options, :multi)
        )
        raise ResolverError.new(_("one of %s not found.") % resource.name, resource) if results.count < expected_record_count(options, resource, :multi)

        results.map { |r| r['id'] }
      end
    end

    def environment_id(options)
      puppet_environment_id(options)
    end

    def puppet_environment_id(options)
      get_id(:environments, options)
    end

    def environment_ids(options)
      puppet_environment_ids(options)
    end

    def puppet_environment_ids(options)
      get_ids(:environments, options)
    end

    def searchables(resource)
      resource = @api.resource(resource) if resource.is_a? Symbol
      @searchables.for(resource)
    end

    protected

    def define_id_finders
      @api.resources.each do |resource|
        method_name = "#{resource.singular_name}_id"
        plural_method_name = "#{resource.singular_name}_ids"

        self.class.send(:define_method, method_name) do |options|
          get_id(resource.name, options)
        end unless respond_to?(method_name, true)

        self.class.send(:define_method, plural_method_name) do |options|
          get_ids(resource.name, options)
        end unless respond_to?(plural_method_name, true)
      end
    end

    def get_id(resource_name, options)
      options[HammerCLI.option_accessor_name("id")] ||
          nil_from_searchables(resource_name, options) ||
          find_resource(resource_name, options)['id']
    end

    def get_ids(resource_name, options)
      if (ids = options[HammerCLI.option_accessor_name("ids")])
        ids
      elsif (ids = nil_from_searchables(resource_name, options, :plural => true))
        ids
      elsif options_not_set?(@api.resource(resource_name), options)
        resource = @api.resource(resource_name)
        raise MissingSearchOptions.new(_("Missing options to search %s") % resource.name, resource)
      elsif options_empty?(@api.resource(resource_name), options)
        []
      else
        find_resources(resource_name, options).map{|r| r['id']}
      end
    end

    def nil_from_searchables(resource_name, options, plural = false)
      resource = @api.resource(resource_name)
      searchables(resource).each do |s|
        option_name = plural ? s.plural_name.to_s : s.name.to_s
        return HammerCLI::NilValue if options[HammerCLI.option_accessor_name(option_name)] == HammerCLI::NilValue
      end
      nil
    end

    def find_resources(resource_name, options)
      resource = @api.resource(resource_name)
      results = resolved_call(resource_name, :index, options, :multi)
      raise ResolverError.new(_("one of %s not found.") % resource.name, resource) if results.count < expected_record_count(options, resource, :multi)
      results
    end

    def find_resource(resource_name, options)
      results = find_resource_raw(resource_name, options)
      resource = @api.resource(resource_name)
      pick_result(results, resource)
    end

    def find_resource_raw(resource_name, options)
      resolved_call(resource_name, :index, options, :single)
    end


    # @param mode [Symbol] mode in which ids are searched :single, :multi, nil for old beahvior
    def resolved_call(resource_name, action_name, options, mode = nil)
      resource = @api.resource(resource_name)
      action = resource.action(action_name)

      search_options = search_options(options, resource, mode)
      IdParamsFilter.new(:only_required => true).for_action(action).each do |param|
        scoped_options_params = [param.name.gsub(/_id$/, ""), options]
        scoped_options_params << mode if method(:scoped_options).arity == -3
        search_options[param.name] ||= send(param.name, scoped_options(*scoped_options_params))
      end
      search_options = route_options(options, action).merge(search_options)
      expected_count = expected_record_count(options, resource, :multi)
      results = retrieve_all(resource, action_name, search_options, expected_count)
      results = HammerCLIForeman.collection_to_common_format(results)
      results
    end

    def retrieve_all(resource, action, search_options, expected_count = 1)
      return resource.call(action, search_options) unless action == :index

      search_options[:per_page] = ALL_PER_PAGE
      search_options[:page] = 1
      data = resource.call(action, search_options)
      last_page = ([expected_count, 1].max.to_f / ALL_PER_PAGE).ceil
      all = data
      while search_options[:page] != last_page
        search_options[:page] += 1
        data = resource.call(action, search_options)
        all = deep_merge(all, data)
      end
      all
    end

    def route_options(options, action)
      return {} if action.routes.any? { |r| r.params_in_path.empty? }

      route_options = {}

      action.routes.each do |route|
        route.params_in_path.each do |param|
          key = HammerCLI.option_accessor_name(param.to_s)
          if options[key]
            route_options[param] ||= options[key]
          end
        end
      end
      route_options
    end

    def pick_result(results, resource)
      raise ResolverError.new(_("%s not found.") % resource.singular_name, resource) if results.empty?
      raise ResolverError.new(_("Found more than one %s.") % resource.singular_name, resource) if results.count > 1
      results[0]
    end

    # @param mode [Symbol] mode in which ids are searched :single, :multi, nil for old beahvior
    def search_options(options, resource, mode = nil)
      override_method = "create_#{resource.name}_search_options"
      search_options = if respond_to?(override_method, true)
        create_search_options_params = [override_method, options]
        if method(override_method.to_sym).arity == -2
          create_search_options_params << mode
        else
          warn "create_*_search_options methods (#{override_method}) without 'mode' parameter are deprecated"
        end
        send(*create_search_options_params)
      else
        create_search_options_params = [options, resource]
        if method(:create_search_options).arity == -3
          create_search_options_params << mode
        else
          warn "create_search_options methods without 'mode' parameter are deprecated"
        end
        create_search_options(*create_search_options_params)
      end
      raise MissingSearchOptions.new(_("Missing options to search %s.") % resource.singular_name, resource) if search_options.empty?
      search_options
    end

    # @param mode [Symbol] mode in which ids are searched :single, :multi, nil for old beahvior
    def expected_record_count(options, resource, mode = nil)
      searchables(resource).each do |s|
        value = options[HammerCLI.option_accessor_name(s.name.to_s)] unless mode == :multi
        values = options[HammerCLI.option_accessor_name(s.plural_name.to_s)] unless mode == :single
        if value
          return 1
        elsif values
          return values.count
        end
      end
      0
    end

    # puppet class search results are in non-standard format
    # and needs to be un-hashed first
    def puppetclass_id(options)
      return options[HammerCLI.option_accessor_name("id")] if options[HammerCLI.option_accessor_name("id")]
      resource = @api.resource(:puppetclasses)
      results = find_resource_raw(:puppetclasses, options)
      require('hammer_cli_foreman/puppet_class')
      results = HammerCLIForeman::PuppetClass::ListCommand.unhash_classes(results)
      pick_result(results, resource)['id']
    end

    def options_empty?(resource, options)
      searchables(resource).all? do |s|
        values = options[HammerCLI.option_accessor_name(s.plural_name.to_s)]
        values.nil? || (values.respond_to?(:empty?) && values.empty?)
      end
    end

    def options_not_set?(resource, options)
      searchables(resource).all? do |s|
        values = options[HammerCLI.option_accessor_name(s.plural_name.to_s)]
        values.nil?
      end
    end

    def create_smart_class_parameters_search_options(options, mode = nil)
      search_options = {}
      value = options[HammerCLI.option_accessor_name('name')]
      search_options[:search] = "key = \"#{value}\""
      search_options[:puppetclass_id] = puppetclass_id(scoped_options("puppetclass", options))
      search_options
    end

    # @param mode [Symbol] mode in which ids are searched :single, :multi, nil for old beahvior
    def create_search_options(options, resource, mode = nil)
      searchables(resource).each do |s|
        value = options[HammerCLI.option_accessor_name(s.name.to_s)]
        values = options[HammerCLI.option_accessor_name(s.plural_name.to_s)]
        if value && (mode.nil? || mode == :single)
          return {:search => "#{s.name} = \"#{value}\""}
        elsif values && (mode.nil? || mode == :multi)
          query = values.map{|v| "#{s.name} = \"#{v}\"" }.join(" or ")
          return {:search => query}
        end
      end
      {}
    end

    private

    def deep_merge(dest, src)
      dest = dest.clone
      dest.merge!(src) do |_key, old_val, new_val|
        if old_val.is_a?(Hash) && new_val.is_a?(Hash)
          deep_merge(old_val, new_val)
        elsif old_val.is_a?(Array) && new_val.is_a?(Array)
          old_val += new_val
        else
          new_val
        end
      end
    end

  end

end
