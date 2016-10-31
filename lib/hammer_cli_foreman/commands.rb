require 'hammer_cli_foreman/api'

module HammerCLIForeman

  RESOURCE_NAME_MAPPING = {
    :usergroup => :user_group,
    :usergroups => :user_groups,
    :ptable => :partition_table,
    :ptables => :partition_tables,
    :puppetclass => :puppet_class,
    :puppetclasses => :puppet_classes
  }

  def self.foreman_api
    foreman_api_connection
  end

  def self.foreman_resource!(resource_name, options={})
    if options[:singular]
      resource_name = ApipieBindings::Inflector.pluralize(resource_name.to_s).to_sym
    else
      resource_name = resource_name.to_sym
    end
    foreman_api.resource(resource_name)
  end

  def self.foreman_resource(resource_name, options={})
    begin
      foreman_resource!(resource_name, options)
    rescue NameError
      nil
    end
  end

  def self.param_to_resource(param_name)
    HammerCLIForeman.foreman_resource(param_name.gsub(/_id[s]?$/, ""), :singular => true)
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
      rescue HammerCLIForeman::MissingSearchOptions => e
        if (options[:required] == true || resource_search_requested(resource, opts))
          logger.info "Error occured while searching for #{resource.singular_name}"
          raise e
        end
      end
    end

    def get_resource_ids(resource, options={})
      opts = resolver.scoped_options(resource.singular_name, all_options)
      begin
        resolver.send("#{resource.singular_name}_ids", opts)
      rescue HammerCLIForeman::MissingSearchOptions => e
        if (options[:required] == true || resource_search_requested(resource, opts, true))
          logger.info "Error occured while searching for #{resource.name}"
          raise e
        end
      end
    end

    def self.resolver
      api = HammerCLI.context[:api_connection].get("foreman")
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
      transform_format(super)
    rescue HammerCLIForeman::MissingSearchOptions => e

      switches = self.class.find_options(:referenced_resource => e.resource.singular_name).map(&:long_switch)

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

    def transform_format(data)
      HammerCLIForeman.record_to_common_format(data)
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

      # resolve all '<resource_name>_ids' parameters if they are defined as options
      IdArrayParamsFilter.new(:only_required => false).for_action(resource.action(action)).each do |api_param|
        param_resource = HammerCLIForeman.param_to_resource(api_param.name)
        if param_resource && respond_to?(HammerCLI.option_accessor_name("#{param_resource.singular_name}_ids"))
          resource_ids = get_resource_ids(param_resource, :scoped => true, :required => api_param.required?)
          params[HammerCLI.option_accessor_name(api_param.name)] = resource_ids if resource_ids
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

    private

    def resource_search_requested(resource, options, plural=false)
      # check if any searchable for given resource is set
      filed_options = Hash[options.select { |opt, value| !value.nil? }].keys
      searchable_options = searchables.for(resource).map do |o|
        HammerCLI.option_accessor_name(plural ? o.plural_name : o.name)
      end
      !(filed_options & searchable_options).empty?
    end

  end


  class ListCommand < Command

    action :index

    RETRIEVE_ALL_PER_PAGE = 1000
    DEFAULT_PER_PAGE = 20

    def adapter
      @context[:adapter] || :table
    end

    def send_request
      set = super
      set.map! { |r| extend_data(r) }
      set
    end

    def transform_format(data)
      HammerCLIForeman.collection_to_common_format(data)
    end

    def extend_data(record)
      record
    end

    def self.command_name(name=nil)
      super(name) || "list"
    end

    def execute
      if should_retrieve_all?
        print_data(retrieve_all)
      else
        self.option_page = (self.option_page || 1).to_i if respond_to?(:option_page)
        self.option_per_page = (self.option_per_page || HammerCLI::Settings.get(:ui, :per_page) || DEFAULT_PER_PAGE).to_i if respond_to?(:option_per_page)
        print_data(send_request)
      end

      return HammerCLI::EX_OK
    end

    protected

    def retrieve_all
      self.option_per_page = RETRIEVE_ALL_PER_PAGE
      self.option_page = 1

      d = send_request
      all = d

      while (d.size == RETRIEVE_ALL_PER_PAGE) do
        self.option_page += 1
        d = send_request
        all += d
      end
      all
    end

    def pagination_supported?
      respond_to?(:option_page) && respond_to?(:option_per_page)
    end

    def should_retrieve_all?
      retrieve_all = pagination_supported? && option_per_page.nil? && option_page.nil?
      retrieve_all &&= HammerCLI::Settings.get(:ui, :per_page).nil? if output.adapter.paginate_by_default?
      retrieve_all
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
      record = super
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

    def self.default_message(format)
      name = associated_resource ? associated_resource.singular_name.to_s : nil
      format % { :resource_name => name.gsub(/_|-/, ' ') } unless name.nil?
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

    def self.failure_message(msg = nil)
      super(msg) || default_message(_('Could not associate the %{resource_name}'))
    end

    def self.success_message(msg = nil)
      super(msg) || default_message(_('The %{resource_name} has been associated'))
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

    def self.failure_message(msg = nil)
      super(msg) || default_message(_('Could not disassociate the %{resource_name}'))
    end

    def self.success_message(msg = nil)
      super(msg) || default_message(_('The %{resource_name} has been disassociated'))
    end
  end
end
