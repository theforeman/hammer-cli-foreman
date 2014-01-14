require 'hammer_cli'

module HammerCLIForeman

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
      raise RuntimeError.new("Received data of unknown format")
    end
    col
  end

  def self.record_to_common_format(data)
      data.class <= Hash && data.keys.length == 1 ? data[data.keys[0]] : data
  end

  class WriteCommand < HammerCLI::Apipie::WriteCommand

    def send_request
      HammerCLIForeman.record_to_common_format(resource.call(action, request_params)[0])
    end

  end

  class ListCommand < HammerCLI::Apipie::ReadCommand

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
      if respond_to?(:page) && respond_to?(:per_page)
        self.page ||= 1
        self.per_page ||= HammerCLI::Settings.get(:ui, :per_page) || DEFAULT_PER_PAGE
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

        if (d.size >= self.per_page.to_i) && interactive?
          answer = ask("List next page? (Y/n): ").downcase
          list_next = (answer == 'y' || answer == '')
          self.page += 1
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


  class InfoCommand < HammerCLI::Apipie::ReadCommand

    action :show

    def self.command_name(name=nil)
      super(name) || "info"
    end

    identifiers :id, :name

    def request_params
      {'id' => get_identifier[0]}
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
      option "--new-name", "NEW_NAME", "new name for the resource", :attribute_name => :option_name if identifier? :name
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
      name = associated_resource.name.to_s
      option_switch = "--"+name.gsub('_', '-')
      option option_switch, name.upcase, " ", :attribute_name => :associated_name if declared_associated_identifiers.include? :name
      option option_switch+"-id", name.upcase+"_ID", " ", :attribute_name => :associated_id if declared_associated_identifiers.include? :id
    end


    def associated_resource
      HammerCLI::Apipie::ResourceInstance.from_definition(self.class.associated_resource, resource_config)
    end

    def self.associated_resource(resource_class=nil)
      @associated_api_resource = HammerCLI::Apipie::ResourceDefinition.new(resource_class) unless resource_class.nil?
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
      item = HammerCLIForeman.record_to_common_format(resource.call('show', {'id' => get_identifier[0]})[0])
      item[associated_resource.name+'_ids'] || []
    end

    def get_required_id
      item = HammerCLIForeman.record_to_common_format(associated_resource.call('show', {'id' => associated_id || associated_name})[0])
      item['id']
    end

    def request_params
      params = method_options
      params[resource.name][associated_resource.name+'_ids'] = get_new_ids
      params['id'] = get_identifier[0]
      params
    end

  end

  class AddAssociatedCommand < AssociatedCommand

    def self.command_name(name=nil)
      super(name) || (associated_resource ? "add_"+associated_resource.name : nil)
    end

    def self.desc(desc=nil)
      "Associate a resource"
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
      super(name) || (associated_resource ? "remove_"+associated_resource.name : nil)
    end

    def self.desc(desc=nil)
      "Disassociate a resource"
    end

    def get_new_ids
      ids = get_current_ids
      required_id = get_required_id

      ids = ids.delete_if { |id| id == required_id }
      ids
    end

  end


end
