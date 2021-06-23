require 'hammer_cli_foreman/api'

module HammerCLIForeman

  RESOURCE_NAME_MAPPING = {
    :usergroup => :user_group,
    :usergroups => :user_groups,
    :ptable => :partition_table,
    :ptables => :partition_tables,
  }

  RESOURCE_ALIAS_NAME_MAPPING = { }

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
      raise RuntimeError.new(_("Received data of unknown format."))
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

    def exception_handler_class
      #search for exception handler class in parent modules/classes
      HammerCLI.constant_path(self.class.name.to_s).reverse.each do |mod|
        return mod.exception_handler_class if mod.respond_to? :exception_handler_class
      end
      HammerCLIForeman::ExceptionHandler
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

    def self.resource_alias_name_mapping
      HammerCLIForeman::RESOURCE_ALIAS_NAME_MAPPING
    end

    def self.alias_name_for_resource(resource, singular: true)
      return nil if resource.nil?
      return resource_alias_name_mapping[resource.name.to_sym] unless singular

      resource_alias_name_mapping[resource.singular_name.to_sym]
    end

    def self.build_options(builder_params={})
      builder_params[:resource_mapping] ||= resource_name_mapping
      builder_params = HammerCLIForeman::BuildParams.new(builder_params)
      yield(builder_params) if block_given?

      super(builder_params.to_hash, &nil)
    end

    def get_identifier(all_opts=all_options)
      @identifier ||= get_resource_id(resource, :all_options => all_opts)
      @identifier
    end

    def get_resource_id(resource, options={})
      resource_alias = self.class.alias_name_for_resource(resource)
      all_opts = options[:all_options] || all_options
      if options[:scoped]
        opts = resolver.scoped_options(resource.singular_name, all_opts, :single)
      else
        opts = all_opts
      end
      begin
        resolver.send("#{resource_alias || resource.singular_name}_id", opts)
      rescue HammerCLIForeman::MissingSearchOptions => e
        if (options[:required] == true || resource_search_requested(resource, opts))
          logger.info "Error occured while searching for #{resource.singular_name}"
          raise e
        end
      end
    end

    def get_resource_ids(resource, options={})
      resource_alias = self.class.alias_name_for_resource(resource)
      all_opts = options[:all_options] || all_options
      opts = resolver.scoped_options(resource.singular_name, all_opts, :multi)
      begin
        resolver.send("#{resource_alias || resource.singular_name}_ids", opts)
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
      data = super
      @meta = retrieve_meta(data)
      transform_format(data)
    end

    def transform_format(data)
      HammerCLIForeman.record_to_common_format(data)
    end

    def customized_options
      # this method is deprecated and will be removed in future versions.
      # Check option_sources for custom tuning of options
      options
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

    extend_with(HammerCLIForeman::CommandExtensions::OptionSources.new)

    protected

    def retrieve_meta(data)
      return unless data.class <= Hash

      {
        total: data['total'].to_i,
        subtotal: data['subtotal'].to_i,
        page: data['page'].to_i,
        per_page: data['per_page'].to_i,
        search: data['search'],
        sort_by: data['sort_by'],
        sort_order: data['sort_order']
      }
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

    def self.output(definition = nil, &block)
      super
      begin
        output_definition.update_field_sets('THIN', (searchables.for(resource).map(&:name) + ['id']).map(&:to_sym))
      rescue StandardError => e
        # Some subcommands may not have such fields or defined resource
      end
    end

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

    def self.command_names(*names)
      super(*names) || %w(list index)
    end

    def execute
      if should_retrieve_all?
        retrieve_all
      else
        self.option_page = (self.option_page || 1).to_i if respond_to?(:option_page)
        self.option_per_page = (self.option_per_page || HammerCLI::Settings.get(:ui, :per_page) || DEFAULT_PER_PAGE).to_i if respond_to?(:option_per_page)
        print_data(send_request)
      end

      return HammerCLI::EX_OK
    end

    def help
      return super unless resource

      meta = resource.action(action).apidoc&.dig(:metadata)
      if meta && meta[:search] && respond_to?(:option_search)
        self.class.extend_help do |h|
          h.section(_('Search / Order fields'), id: :search_fields_section) do |h|
            h.list(search_fields_help(meta[:search]))
          end
        end
      end
      super
    end

    extend_with(HammerCLIForeman::CommandExtensions::Fields.new)

    protected

    def retrieve_all
      self.option_per_page = RETRIEVE_ALL_PER_PAGE
      self.option_page = 1

      loop do
        data = send_request
        print_data(data, current_chunk: current_chunk)
        break unless data.size == RETRIEVE_ALL_PER_PAGE

        self.option_page += 1
      end
    end

    def pagination_supported?
      respond_to?(:option_page) && respond_to?(:option_per_page)
    end

    def should_retrieve_all?
      retrieve_all = pagination_supported? && option_per_page.nil? && option_page.nil?
      retrieve_all &&= HammerCLI::Settings.get(:ui, :per_page).nil? if output.adapter.paginate_by_default?
      retrieve_all
    end

    def search_fields_help(search_fields)
      return [] if search_fields.nil?

      search_fields.each_with_object([]) do |field, help_list|
        help_list << [
          field[:name], search_field_help_value(field)
        ]
      end
    end

    def search_field_help_value(field)
      if field[:values] && field[:values].is_a?(Array)
        _('Values') + ': ' + field[:values].join(', ')
      else
        field[:type] || field[:values]
      end
    end

    def current_chunk
      return :single unless @meta

      first_chunk = @meta[:page] == 1
      last_chunk = @meta[:per_page] * @meta[:page] >= @meta[:subtotal]
      return :single if first_chunk && last_chunk
      return :first if first_chunk
      return :last if last_chunk

      :another
    end
  end

  class AssociatedListSearchCommand < ListCommand
    def self.search_resource(res, action = :index)
      resource res, action
      default_search_options
    end

    def self.default_search_options
      option("--id", "ID", _("%s Id") % module_resource.singular_name)
      option("--name", "NAME", _("%s name") % module_resource.singular_name)
    end

    def self.search_options_mapping(mapping = {})
      { "name" => module_resource.singular_name,
        "id" => "#{module_resource.singular_name}_id"
      }.merge mapping
    end

    def option_sources
      sources = super
      sources.find_by_name('IdResolution').insert_relative(
        :replace,
        'SelfParam',
         HammerCLI::Options::Sources::Base.new
      )
      sources
    end

    def validate_options
      super
      validator.any("option_name".to_sym, "option_id".to_sym).required
    end

    def parent_resource_name
      self.class.module_resource.singular_name
    end

    def search_mapping(key)
      self.class.search_options_mapping[key]
    end

    def parent_resource_name_attr
      "name"
    end

    def parent_resource_id_attr
      "id"
    end

    def name_attr(resource_name)
      "#{resource_name}_name"
    end

    def id_attr(resource_name)
      "#{resource_name}_id"
    end

    def request_params
      params = super
      search = []
      search << params['search'] if params['search']

      resource_name = get_option_value(parent_resource_name_attr)
      search << %Q(#{search_mapping parent_resource_name_attr}="#{resource_name}") if resource_name

      resource_id = get_option_value(parent_resource_id_attr)
      search << "#{search_mapping parent_resource_id_attr}=#{resource_id}" if resource_id

      search += taxonomy_request_params('organization', params)
      search += taxonomy_request_params('location', params)

      params['search'] = search.join(' and ') unless search.empty?
      params
    end

    def taxonomy_request_params(taxonomy, params)
      res = []
      tax_name = get_option_value(name_attr taxonomy)
      if tax_name
        res << "#{name_attr taxonomy}=#{tax_name}"
        params.delete(name_attr taxonomy)
      end

      tax_id = get_option_value(id_attr taxonomy)
      if tax_id
        res << "#{id_attr taxonomy}=#{tax_id}"
        params.delete(id_attr taxonomy)
      end
      res
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

    def self.output(definition = nil, &block)
      super
      begin
        output_definition.update_field_sets('THIN', (searchables.for(resource).map(&:name) + ['id']).map(&:to_sym))
      rescue StandardError => e
        # Some subcommands may not have such fields or defined resource
      end
    end

    def self.command_names(*names)
      super(*names) || %w(info show)
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

    extend_with(HammerCLIForeman::CommandExtensions::Fields.new)
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

    def self.inherited(child)
      child.success_message_for(:nothing_to_do, _('Nothing to update.'))
    end

    def clean_up_context
      super
      context.delete(:action_message)
    end

    def success_message
      success_message_for(context[:action_message] || :default)
    end

    def method_options_for_params(params, options)
      opts = super
      # overwrite searchables with correct values
      searchables.for(resource).each do |s|
        next unless params.map(&:name).include?(s.name)

        new_value = get_option_value("new_#{s.name}")
        opts[s.name] = new_value unless new_value.nil?
      end
      opts
    end

    extend_with(HammerCLIForeman::CommandExtensions::UpdateCommon.new)
  end


  class DeleteCommand < SingleResourceCommand

    action :destroy

    def self.command_names(*names)
      super(*names) || %w(delete destroy)
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

    def get_associated_identifiers
      get_resource_ids(associated_resource, :scoped => true)
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
      super(msg) || default_message(_('Could not associate the %{resource_name}.'))
    end

    def self.success_message(msg = nil)
      super(msg) || default_message(_('The %{resource_name} has been associated.'))
    end

    def get_new_ids
      ids = get_current_ids.map(&:to_s)

      associated_identifiers = get_associated_identifiers
      associated_identifier = get_associated_identifier

      required_ids = associated_identifiers.nil? ? [] : associated_identifiers.map(&:to_s)
      required_ids << associated_identifier.to_s unless associated_identifier.nil?

      ids += required_ids
      ids.uniq
    end

  end

  class RemoveAssociatedCommand < AssociatedCommand

    def self.command_name(name=nil)
      name = super(name) || (associated_resource ? "remove-" + associated_resource.singular_name : nil)
      name.respond_to?(:gsub) ? name.gsub('_', '-') : name
    end

    def self.desc(desc=nil)
      description = super(desc) || ''
      description.strip.empty? ? _("Disassociate a resource") : description
    end

    def get_new_ids
      ids = get_current_ids.map(&:to_s)

      associated_identifiers = get_associated_identifiers
      associated_identifier = get_associated_identifier

      required_ids = associated_identifiers.nil? ? [] : associated_identifiers.map(&:to_s)
      required_ids << associated_identifier.to_s unless associated_identifier.nil?

      ids = ids.delete_if { |id| required_ids.include? id }
      ids
    end

    def self.failure_message(msg = nil)
      super(msg) || default_message(_('Could not disassociate the %{resource_name}.'))
    end

    def self.success_message(msg = nil)
      super(msg) || default_message(_('The %{resource_name} has been disassociated.'))
    end
  end

  class DownloadCommand < HammerCLIForeman::SingleResourceCommand
    action :download

    def self.command_name(name = nil)
      super(name) || "download"
    end

    def request_options
      { :response => :raw }
    end

    option "--path", "PATH", _("Path to directory where downloaded content will be saved"),
        :attribute_name => :option_path

    def execute
      response = send_request
      if option_path
        filepath = store_response(response)
        print_message(_('The response has been saved to %{path}s.'), {:path => filepath})
      else
        puts response.body
      end
      return HammerCLI::EX_OK
    end

    def default_filename
      "Downloaded-#{Time.new.strftime("%Y-%m-%d")}.txt"
    end

    private

    def store_response(response)
      if response.headers.key?(:content_disposition)
        suggested_filename = response.headers[:content_disposition].match(/filename="(.*)"/)
      end
      filename = suggested_filename ? suggested_filename[1] : default_filename
      path = option_path.dup
      path << '/' unless path.end_with? '/'
      raise _("Cannot save file: %s does not exist") % path unless File.directory?(path)
      filepath = path + filename
      File.write(filepath, response.body)
      filepath
    end
  end
end
