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

  class ReadCommand < HammerCLI::Apipie::ReadCommand
    extend HammerCLIForeman::ConnectionSetup
  end

  class Command < ReadCommand
  end

  class WriteCommand < HammerCLI::Apipie::WriteCommand
    extend HammerCLIForeman::ConnectionSetup

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

  end


  class InfoCommand < ReadCommand

    action :show

    def self.command_name(name=nil)
      super(name) || "info"
    end

    identifiers :id, :name

    def request_params
      params = method_options
      params.update('id' => get_identifier[0])
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

  end


  class UpdateCommand < WriteCommand

    action :update

    def self.command_name(name=nil)
      super(name) || "update"
    end

    identifiers :id, :name => :option_current_name

    def self.setup_identifier_options
      super
      option "--new-name", "NEW_NAME", _("new name for the resource"), :attribute_name => :option_name if identifier? :name
    end

    def request_params
      params = method_options
      params['id'] = get_identifier[0]
      params
    end

  end


  class DeleteCommand < WriteCommand

    action :destroy

    def self.command_name(name=nil)
      super(name) || "delete"
    end

    identifiers :id, :name

    def request_params
      {'id' => get_identifier[0]}
    end

  end


  class AssociatedCommand < WriteCommand

    identifiers :name, :id
    action :update

    def validate_options
      associated_ids = self.class.declared_associated_identifiers.collect {|id_name| "associated_#{id_name}" }
      validator.any(*associated_ids).required
      validator.any(*self.class.declared_identifiers.values).required
    end

    def self.apipie_options(options={})
      setup_associated_identifier_options
      super
    end

    def self.setup_associated_identifier_options
      name = associated_resource.singular_name
      option_switch = "--"+name.gsub('_', '-')

      option option_switch, name.upcase, " ", :attribute_name => :associated_name do |value|
        name_to_id(value, "name", associated_resource)
      end if declared_associated_identifiers.include? :name
      option option_switch+"-id", name.upcase+"_ID", " ", :attribute_name => :associated_id if declared_associated_identifiers.include? :id
    end


    def associated_resource
      self.class.associated_resource
    end

    def self.associated_resource(resource_class=nil)
      @associated_api_resource = HammerCLIForeman.foreman_resource(resource_class) unless resource_class.nil?
      return @associated_api_resource
    end



    def self.associated_identifiers(*keys)
      @associated_identifiers = keys
    end

    def self.declared_associated_identifiers
      if @associated_identifiers
        return @associated_identifiers
      elsif superclass.respond_to?(:declared_associated_identifiers, true)
        superclass.declared_associated_identifiers
      else
        []
      end
    end

    associated_identifiers :name, :id

    def get_new_ids
      []
    end

    def get_current_ids
      item = HammerCLIForeman.record_to_common_format(resource.call(:show, {:id => get_identifier[0]}))
      if item.has_key?(association_name(true))
        item[association_name(true)].map { |assoc| assoc['id'] }
      else
        item[association_name+'_ids'] || []
      end
    end

    def get_required_id
      item = HammerCLIForeman.record_to_common_format(associated_resource.call(:show, {:id => associated_id || associated_name}))
      item['id']
    end

    def request_params
      params = super
      if params.key?(resource.singular_name)
        params[resource.singular_name] = {"#{association_name}_ids" => get_new_ids }
      else
        params["#{association_name}_ids"] = get_new_ids
      end
      params['id'] = get_identifier[0]
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
      ids = get_current_ids
      required_id = get_required_id

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
      ids = get_current_ids
      required_id = get_required_id

      ids = ids.delete_if { |id| id == required_id }
      ids
    end

  end


end
