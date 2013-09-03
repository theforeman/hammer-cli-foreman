require 'hammer_cli'

module HammerCLIForeman

  class ListCommand < HammerCLI::Apipie::ReadCommand

    def self.command_name(name=nil)
      super(name) || "list"
    end

    def output
      @output ||= HammerCLI::Output::Output.new(
            :definition => output_definition,
            :adapter => HammerCLI::Output::Adapter::Table.new)

    end

  end


  class InfoCommand < HammerCLI::Apipie::ReadCommand

    def self.command_name(name=nil)
      super(name) || "info"
    end

    identifiers :id, :name

    def request_params
      {'id' => get_identifier[0]}
    end

    def self.apipie_options options={}
      super(options.merge(:without => declared_identifiers.keys))
    end
  end


  class CreateCommand < HammerCLI::Apipie::WriteCommand

    def self.command_name(name=nil)
      super(name) || "create"
    end

  end


  class UpdateCommand < HammerCLI::Apipie::WriteCommand

    def self.command_name(name=nil)
      super(name) || "update"
    end

    identifiers :id, :name => :current_name

    def setup_identifier_options
      super
      self.class.option "--new-name", "NEW_NAME", "new name for the resource", :attribute_name => :name if self.class.identifier? :name
    end

    def request_params
      params = method_options
      params['id'] = get_identifier[0]
      params
    end

    def self.apipie_options options={}
      super({:without => declared_identifiers.keys}.merge(options))
    end

  end


  class DeleteCommand < HammerCLI::Apipie::WriteCommand

    def self.command_name(name=nil)
      super(name) || "delete"
    end

    identifiers :id, :name

    def request_params
      {'id' => get_identifier[0]}
    end

    def self.apipie_options options={}
      super({:without => declared_identifiers.keys}.merge(options))
    end

  end


  class AssociatedCommand < HammerCLI::Apipie::WriteCommand

    identifiers :name, :id
    action "update"

    def validate_options
      associated_ids = self.class.declared_associated_identifiers.collect {|id_name| "associated_"+id_name.to_s }
      validator.any(*associated_ids).required
      validator.any(*self.class.declared_identifiers.values).required
    end

    def initialize(*args)
      setup_associated_identifier_options
      super(*args)
    end

    def setup_associated_identifier_options
      name = associated_resource_name
      self.class.option "--"+name.to_s, name.to_s.upcase, " ", :attribute_name => :associated_name if self.class.declared_associated_identifiers.include? :name
      self.class.option "--"+name.to_s+"-id", name.to_s.upcase+"_ID", " ", :attribute_name => :associated_id if self.class.declared_associated_identifiers.include? :id
    end

    def associated_resource
      @associated_resource ||= self.class.associated_resource.new resource_config
      @associated_resource
    end

    def associated_resource_name
      self.class.associated_resource_name
    end

    def self.associated_resource_name
      associated_resource.name.split("::")[-1].downcase
    end

    def self.associated_resource resource=nil
      @associated_api_resource = resource unless resource.nil?
      return @associated_api_resource
    end

    def self.associated_identifiers *keys
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
      item = resource.send('show', {'id' => get_identifier[0]})[0]
      item[resource_name][associated_resource_name+'_ids'] || []
    end

    def get_required_id
      item = associated_resource.send('show', {'id' => associated_id || associated_name})[0]
      item[associated_resource_name]['id']
    end

    def request_params
      params = method_options
      params[resource_name][associated_resource_name+'_ids'] = get_new_ids
      params['id'] = get_identifier[0]
      params
    end

  end

  class AddAssociatedCommand < AssociatedCommand

    def self.command_name(name=nil)
      super(name) || "add_"+associated_resource_name
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
      super(name) || "remove_"+associated_resource_name
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
