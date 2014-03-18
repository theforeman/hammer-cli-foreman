module HammerCLIForeman

  CONNECTION_NAME = 'foreman'

  def self.credentials
    @credentials ||= Credentials.new(
      :username => (HammerCLI::Settings.get(:_params, :username) || ENV['FOREMAN_USERNAME'] || HammerCLI::Settings.get(:foreman, :username)),
      :password => (HammerCLI::Settings.get(:_params, :password) || ENV['FOREMAN_PASSWORD'] || HammerCLI::Settings.get(:foreman, :password))
    )
    @credentials
  end

  def self.resource_config
    config = {}
    config[:uri] = HammerCLI::Settings.get(:foreman, :host)
    config[:credentials] = credentials
    config[:logger] = Logging.logger['API']
    config[:api_version] = 2
    config[:aggressive_cache_checking] = HammerCLI::Settings.get(:foreman, :refresh_cache) || true
    config[:headers] = { "Accept-Language" => HammerCLI::I18n.locale }
    config[:timeout] = HammerCLI::Settings.get(:foreman, :request_timeout)
    config
  end

  def self.foreman_resource(resource)
    HammerCLI::Connection.create(
        CONNECTION_NAME,
        HammerCLI::Apipie::Command.resource_config.merge(resource_config),
        HammerCLI::Apipie::Command.connection_options).api.resource(resource)
  end

  module ConnectionSetup
    def connection_name(resource_class)
      CONNECTION_NAME
    end

    def resource_config
      super.merge(HammerCLIForeman.resource_config)
    end
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


  module ResolverCommons

    def self.included(base)
      base.extend(ClassMethods)
    end

    def resolver
      self.class.resolver
    end

    def searchables
      self.class.searchables
    end

    def get_identifier
      @identifier ||= resolver.send("#{resource.singular_name}_id", all_options)
      @identifier
    end

    module ClassMethods

      def resolver
        api = HammerCLI::Connection.get("foreman").api
        HammerCLIForeman::IdResolver.new(api, HammerCLIForeman::Searchables.new)
      end

      def searchables
        @searchables ||= HammerCLIForeman::Searchables.new
        @searchables
      end

    end
  end


  class ReadCommand < HammerCLI::Apipie::ReadCommand
    extend HammerCLIForeman::ConnectionSetup
    include HammerCLIForeman::ResolverCommons
  end

  class Command < ReadCommand
  end

  class WriteCommand < HammerCLI::Apipie::WriteCommand
    extend HammerCLIForeman::ConnectionSetup
    include HammerCLIForeman::ResolverCommons

    def send_request
      HammerCLIForeman.record_to_common_format(super)
    end

  end

  class ListCommand < ReadCommand

    action :index

    DEFAULT_PER_PAGE = 20

    def adapter
      :table
    end

    def retrieve_data
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
        self.option_page ||= 1
        self.option_per_page ||= HammerCLI::Settings.get(:ui, :per_page) || DEFAULT_PER_PAGE
        browse_collection
      else
        retrieve_and_print
      end

      return HammerCLI::EX_OK
    end

    protected

    def request_params
      params = method_options
      required_params = resource.action(action).params.select{|p| p.required? && p.name.end_with?("_id") }
      required_params.each do |p|
        resource_name = p.name.gsub(/_id$/, "")
        opts = resolver.scoped_options(resource_name, all_options)
        params[p.name] = resolver.send(p.name.to_s, opts)
      end
      params
    end

    def browse_collection
      list_next = true

      while list_next do
        d = retrieve_and_print

        if (d.size >= self.option_per_page.to_i) && interactive?
          answer = ask(_("List next page? (%s): ") % 'Y/n').downcase
          list_next = (answer == 'y' || answer == '')
          self.option_page += 1
        else
          list_next = false
        end
      end
    end

    def retrieve_and_print
      d = retrieve_data
      logger.watch "Retrieved data: ", d
      print_data d
      d
    end

    def self.custom_option_builders
      builders = super
      if resource_defined?
        builders += [
          DependentSearchablesOptionBuilder.new(resolver.dependent_resources(resource), searchables)
        ]
      end
      builders
    end

  end


  class InfoCommand < ReadCommand

    action :show

    def self.command_name(name=nil)
      super(name) || "info"
    end

    def self.custom_option_builders
      builders = super
      if resource_defined?
        builders += [
          SearchablesOptionBuilder.new(resource, searchables),
          DependentSearchablesOptionBuilder.new(resolver.dependent_resources(resource), searchables)
        ]
      end
      builders
    end

    def request_params
      params = method_options
      params['id'] ||= get_identifier
      params
    end

    def retrieve_data
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


  class CreateCommand < WriteCommand

    action :create

    def self.command_name(name=nil)
      super(name) || "create"
    end

    def self.custom_option_builders
      builders = super
      if resource_defined?
        builders += [
          SearchablesOptionBuilder.new(resource, searchables),
          DependentSearchablesOptionBuilder.new(resolver.dependent_resources(resource), searchables)
        ]
      end
      builders
    end

  end


  class UpdateCommand < WriteCommand

    action :update

    def self.command_name(name=nil)
      super(name) || "update"
    end

    def self.custom_option_builders
      builders = super
      if resource_defined?
        builders += [
          SearchablesOptionBuilder.new(resource, searchables),
          DependentSearchablesOptionBuilder.new(resolver.dependent_resources(resource), searchables),
          SearchablesUpdateOptionBuilder.new(resource, searchables)
        ]
      end
      builders
    end

    def request_params
      params = method_options
      params['id'] = get_identifier
      params
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


  class DeleteCommand < WriteCommand

    action :destroy

    def self.command_name(name=nil)
      super(name) || "delete"
    end

    def self.custom_option_builders
      builders = super
      if resource_defined?
        builders += [
          SearchablesOptionBuilder.new(resource, searchables),
          DependentSearchablesOptionBuilder.new(resolver.dependent_resources(resource), searchables)
        ]
      end
      builders
    end

    def request_params
      params = method_options
      params['id'] = get_identifier
      params
    end

  end


  class AssociatedCommand < WriteCommand

    option "--id", "ID", " "

    action :update

    def self.custom_option_builders
      [
        SearchablesOptionBuilder.new(resource, searchables),
        DependentSearchablesOptionBuilder.new(resolver.dependent_resources(resource), searchables),
        DependentSearchablesOptionBuilder.new(associated_resource, searchables),
        DependentSearchablesOptionBuilder.new(resolver.dependent_resources(associated_resource), searchables)
      ]
    end

    def associated_resource
      self.class.associated_resource
    end

    def self.associated_resource(resource_class=nil)
      @associated_api_resource = HammerCLIForeman.foreman_resource(resource_class) unless resource_class.nil?
      return @associated_api_resource if @associated_api_resource
      return superclass.associated_resource if superclass.respond_to? :associated_resource
    end

    def get_associated_identifier
      opts = resolver.scoped_options(associated_resource.singular_name, all_options)
      resolver.send("#{associated_resource.singular_name}_id", opts)
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
      _("Associate a resource")
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
      _("Disassociate a resource")
    end

    def get_new_ids
      ids = get_current_ids.map(&:to_s)
      required_id = get_associated_identifier.to_s

      ids = ids.delete_if { |id| id == required_id }
      ids
    end

  end


end
