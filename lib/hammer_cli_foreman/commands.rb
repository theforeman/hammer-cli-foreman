require 'hammer_cli'

module HammerCLIForeman

  class ListCommand < HammerCLI::Apipie::ReadCommand

  end


  class InfoCommand < HammerCLI::Apipie::ReadCommand

    option "--id", "ID", "resource id"
    option "--name", "NAME", "resource name"

    def validate_options
      validator.any(:name, :id).required
    end

    def request_params
      {'id' => (id || name)}
    end

    def self.apipie_options options={}
      super(options.merge(:without => ["name", "id"]))
    end
  end


  class CreateCommand < HammerCLI::Apipie::WriteCommand

  end


  class UpdateCommand < HammerCLI::Apipie::WriteCommand

    option "--id", "ID", "resource id"
    option "--name", "NAME", "resource name", :attribute_name => :current_name
    option "--new-name", "NEW_NAME", "new name for the resource", :attribute_name => :name

    def validate_options
      validator.any(:current_name, :id).required
    end

    def request_params
      params = method_options
      params['id'] = id || current_name
      params
    end

    def self.apipie_options options={}
      super({:without => ['name', 'id']}.merge(options))
    end

  end


  class DeleteCommand < HammerCLI::Apipie::WriteCommand

    option "--id", "ID", "resource id"
    option "--name", "NAME", "resource name"

    def validate_options
      validator.any(:name, :id).required
    end

    def request_params
      {'id' => (id || name)}
    end

    def self.apipie_options options={}
      super(options.merge(:without => ["name", "id"]))
    end

  end


end
