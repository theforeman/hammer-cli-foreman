module HammerCLIForeman

  CONNECTION_NAME = 'foreman'

  RESOURCE_NAME_MAPPING = {
    :usergroup => :user_group
  }

  def self.credentials
    @credentials ||= BasicCredentials.new(
      :username => (HammerCLI::Settings.get(:_params, :username) || ENV['FOREMAN_USERNAME'] || HammerCLI::Settings.get(:foreman, :username)),
      :password => (HammerCLI::Settings.get(:_params, :password) || ENV['FOREMAN_PASSWORD'] || HammerCLI::Settings.get(:foreman, :password))
    )
    @credentials
  end

  def self.resource_config
    config = {}
    config[:uri] = HammerCLI::Settings.get(:_params, :host) || HammerCLI::Settings.get(:foreman, :host)
    config[:credentials] = credentials
    config[:logger] = Logging.logger['API']
    config[:api_version] = 2
    config[:aggressive_cache_checking] = HammerCLI::Settings.get(:foreman, :refresh_cache) || false
    config[:headers] = { "Accept-Language" => HammerCLI::I18n.locale }
    config[:language] = HammerCLI::I18n.locale
    config[:timeout] = HammerCLI::Settings.get(:foreman, :request_timeout)
    config[:timeout] = -1 if (config[:timeout] && config[:timeout].to_i < 0)
    config[:apidoc_authenticated] = false
    config
  end

  def self.foreman_api_connection
    HammerCLI::Connection.create(
      CONNECTION_NAME,
      HammerCLI::Apipie::Command.resource_config.merge(resource_config),
      HammerCLI::Apipie::Command.connection_options
    )
  end

  def self.foreman_resource!(resource_name, options={})
    if options[:singular]
      resource_name = ApipieBindings::Inflector.pluralize(resource_name.to_s).to_sym
    else
      resource_name = resource_name.to_sym
    end
    foreman_api_connection.api.resource(resource_name)
  end

  def self.foreman_resource(resource_name, options={})
    begin
      foreman_resource!(resource_name, options)
    rescue NameError
      nil
    end
  end

  def self.param_to_resource(param_name)
    HammerCLIForeman.foreman_resource(param_name.gsub(/_id$/, ""), :singular => true)
  end

  def self.collection_to_common_format(data)
    if data.class <= Hash && data.has_key?('total') && data.has_key?('results')
      col = HammerCLI::Output::RecordCollection.new(data['results'],
        :total => data['total'],
        :subtotal => data['subtotal'],
        :page => data['page'],
        :per_page => data['per_page'],
        :search => data['search'],
        :sort_by => data['sort']['by'],
        :sort_order => data['sort']['order'])
    elsif data.class <= Hash
      col = HammerCLI::Output::RecordCollection.new(data)
    elsif data.class <= Array
      # remove object types. From [ { 'type' => { 'attr' => val } }, ... ]
      # produce [ { 'attr' => 'val' }, ... ]
      col = HammerCLI::Output::RecordCollection.new(data.map { |r| r.keys.length == 1 ? r[r.keys[0]] : r })
    else
      raise RuntimeError.new(_("Received data of unknown format"))
    end
    col
  end

  def self.record_to_common_format(data)
      data.class <= Hash && data.keys.length == 1 ? data[data.keys[0]] : data
  end


  class Command < HammerCLI::Apipie::Command

    def self.connection_name(resource_class)
      CONNECTION_NAME
    end

    def self.resource_config
      super.merge(HammerCLIForeman.resource_config)
    end

    def resolver
      self.class.resolver
    end

    def dependency_resolver
      self.class.dependency_resolver
    end

    def searchables
      self.class.searchables
    end

    def self.create_option_builder
      configurator = BuilderConfigurator.new(searchables, dependency_resolver)

      builder = ForemanOptionBuilder.new(searchables)
      builder.builders = []
      builder.builders += configurator.builders_for(resource, resource.action(action)) if resource_defined?
      builder.builders += super.builders
      builder
    end

    def self.resource_name_mapping
      HammerCLIForeman::RESOURCE_NAME_MAPPING
    end

    def self.build_options(builder_params={})
      builder_params[:resource_mapping] ||= resource_name_mapping
      builder_params = HammerCLIForeman::BuildParams.new(builder_params)
      yield(builder_params) if block_given?

      super(builder_params.to_hash, &nil)
    end

    def get_identifier
      @identifier ||= get_resource_id(resource)
      @identifier
    end

    def get_resource_id(resource, options={})
      if options[:scoped]
        opts = resolver.scoped_options(resource.singular_name, all_options)
      else
        opts = all_options
      end
      begin
        resolver.send("#{resource.singular_name}_id", opts)
      rescue HammerCLIForeman::MissingSeachOptions => e
        raise e unless (options[:required] == false)
      end
    end

    def self.resolver
      api = HammerCLI::Connection.get("foreman").api
      HammerCLIForeman::IdResolver.new(api, HammerCLIForeman::Searchables.new)
    end

    def self.dependency_resolver
      HammerCLIForeman::DependencyResolver.new
    end

    def self.searchables
      @searchables ||= HammerCLIForeman::Searchables.new
      @searchables
    end

    def send_request
      HammerCLIForeman.record_to_common_format(super)
    end

    def customized_options
      params = options
      # resolve all '<resource_name>_id' parameters if they are defined as options
      # (they can be skipped using .without or .expand.except)
      IdParamsFilter.new(:only_required => false).for_action(resource.action(action)).each do |api_param|
        param_resource = HammerCLIForeman.param_to_resource(api_param.name)
        if param_resource && respond_to?(HammerCLI.option_accessor_name("#{param_resource.singular_name}_id"))
          resource_id = get_resource_id(param_resource, :scoped => true, :required => api_param.required?)
          params[HammerCLI.option_accessor_name(api_param.name)] = resource_id if resource_id
        end
      end
      # resolve 'id' parameter if it's defined as an option
      id_option_name = HammerCLI.option_accessor_name('id')
      params[id_option_name] ||= get_identifier if respond_to?(id_option_name)
      params
    end

    def request_params
      params = customized_options
      params_pruned = method_options(params)

      # Options defined manualy in commands are removed in method_options.
      # Manual ids are common so its handling is covered here
      id_option_name = HammerCLI.option_accessor_name('id')
      params_pruned['id'] = params[id_option_name] if params[id_option_name]
      params_pruned
    end
  end


  class ListCommand < Command

    action :index

    DEFAULT_PER_PAGE = 20

    def adapter
      @context[:adapter] || :table
    end

    def send_request
      data = super
      set = HammerCLIForeman.collection_to_common_format(data)
      set.map! { |r| extend_data(r) }
      set
    end

    def extend_data(record)
      record
    end

    def self.command_name(name=nil)
      super(name) || "list"
    end

    def execute
      if respond_to?(:option_page) && respond_to?(:option_per_page)
        self.option_page = (self.option_page || 1).to_i
        self.option_per_page ||= HammerCLI::Settings.get(:ui, :per_page) || DEFAULT_PER_PAGE
        browse_collection
      else
        retrieve_and_print
      end

      return HammerCLI::EX_OK
    end

    protected


    def browse_collection
      list_next = true

      while list_next do
        d = retrieve_and_print

        if (d.size >= self.option_per_page.to_i) && interactive? && adapter != :csv
          answer = ask(_("List next page? (%s): ") % 'Y/n').downcase
          list_next = (answer == 'y' || answer == '')
          self.option_page += 1
        else
          list_next = false
        end
      end
    end

    def retrieve_and_print
      d = send_request
      print_data d
      d
    end

  end


  class SingleResourceCommand < Command

  end


  class AssociatedResourceListCommand < ListCommand

    def parent_resource
      self.class.parent_resource
    end

    def self.parent_resource(name=nil)
      @parent_api_resource = HammerCLIForeman.foreman_resource!(name) unless name.nil?
      return @parent_api_resource if @parent_api_resource
      return superclass.parent_resource if superclass.respond_to? :parent_resource
    end

    def self.create_option_builder
      builder = super
      builder.builders << SearchablesOptionBuilder.new(parent_resource, searchables)
      builder.builders << IdOptionBuilder.new(parent_resource)
      builder
    end

    def request_params
      id_param_name = "#{parent_resource.singular_name}_id"

      params = super
      params[id_param_name] = get_resource_id(parent_resource)
      params
    end

  end


  class InfoCommand < SingleResourceCommand

    action :show

    def self.command_name(name=nil)
      super(name) || "info"
    end

    def send_request
      data = super
      record = HammerCLIForeman.record_to_common_format(data)
      extend_data(record)
    end

    def extend_data(record)
      record
    end

    def print_data(record)
      print_record(output_definition, record)
    end

  end


  class CreateCommand < Command

    action :create

    def self.command_name(name=nil)
      super(name) || "create"
    end

  end


  class UpdateCommand < SingleResourceCommand

    action :update

    def self.command_name(name=nil)
      super(name) || "update"
    end

    def self.create_option_builder
      builder = super
      builder.builders << SearchablesUpdateOptionBuilder.new(resource, searchables) if resource_defined?
      builder
    end

    def method_options_for_params(params, include_nil=true)
      opts = super
      # overwrite searchables with correct values
      searchables.for(resource).each do |s|
        new_value = get_option_value("new_#{s.name}")
        opts[s.name] = new_value unless new_value.nil?
      end
      opts
    end

  end


  class DeleteCommand < SingleResourceCommand

    action :destroy

    def self.command_name(name=nil)
      super(name) || "delete"
    end

  end


  class AssociatedCommand < Command

    action :update

    def self.create_option_builder
      configurator = BuilderConfigurator.new(searchables, dependency_resolver)

      builder = ForemanOptionBuilder.new(searchables)
      builder.builders = [
        SearchablesOptionBuilder.new(resource, searchables),
        DependentSearchablesOptionBuilder.new(associated_resource, searchables)
      ]

      resources = []
      resources += dependency_resolver.resource_dependencies(resource, :only_required => true, :recursive => true)
      resources += dependency_resolver.resource_dependencies(associated_resource, :only_required => true, :recursive => true)
      resources.each do |r|
        builder.builders << DependentSearchablesOptionBuilder.new(r, searchables)
      end
      builder.builders << IdOptionBuilder.new(resource)

      builder
    end

    def associated_resource
      self.class.associated_resource
    end

    def self.associated_resource(name=nil)
      @associated_api_resource = HammerCLIForeman.foreman_resource!(name) unless name.nil?
      return @associated_api_resource if @associated_api_resource
      return superclass.associated_resource if superclass.respond_to? :associated_resource
    end

    def get_associated_identifier
      get_resource_id(associated_resource, :scoped => true)
    end

    def get_new_ids
      []
    end

    def get_current_ids
      item = HammerCLIForeman.record_to_common_format(resource.call(:show, {:id => get_identifier}))
      if item.has_key?(association_name(true))
        item[association_name(true)].map { |assoc| assoc['id'] }
      else
        item[association_name+'_ids'] || []
      end
    end

    def request_params
      params = super
      if params.key?(resource.singular_name)
        params[resource.singular_name] = {"#{association_name}_ids" => get_new_ids }
      else
        params["#{association_name}_ids"] = get_new_ids
      end
      params['id'] = get_identifier
      params
    end

    def association_name(plural = false)
      plural ? associated_resource.name.to_s : associated_resource.singular_name.to_s
    end

  end

  class AddAssociatedCommand < AssociatedCommand

    def self.command_name(name=nil)
      name = super(name) || (associated_resource ? "add-"+associated_resource.singular_name : nil)
      name.respond_to?(:gsub) ? name.gsub('_', '-') : name
    end

    def self.desc(desc=nil)
      description = super(desc) || ''
      description.strip.empty? ? _("Associate a resource") : description
    end

    def get_new_ids
      ids = get_current_ids.map(&:to_s)
      required_id = get_associated_identifier.to_s

      ids << required_id unless ids.include? required_id
      ids
    end

  end

  class RemoveAssociatedCommand < AssociatedCommand

    def self.command_name(name=nil)
      name = super(name) || (associated_resource ? "remove-"+associated_resource.singular_name : nil)
      name.respond_to?(:gsub) ? name.gsub('_', '-') : name
    end

    def self.desc(desc=nil)
      description = super(desc) || ''
      description.strip.empty? ? _("Disassociate a resource") : description
    end

    def get_new_ids
      ids = get_current_ids.map(&:to_s)
      required_id = get_associated_identifier.to_s

      ids = ids.delete_if { |id| id == required_id }
      ids
    end

  end


end
