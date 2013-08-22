require 'hammer_cli'

module HammerCLIForeman

  class ListCommand < HammerCLI::Apipie::ReadCommand

  end


  class InfoCommand < HammerCLI::Apipie::ReadCommand

    identifiers :id, :name

    def request_params
      {'id' => get_identifier[0]}
    end

    def self.apipie_options options={}
      super(options.merge(:without => declared_identifiers))
    end
  end


  class CreateCommand < HammerCLI::Apipie::WriteCommand

  end


  class UpdateCommand < HammerCLI::Apipie::WriteCommand

    identifiers :id, :name

    def setup_identifier_options
      super
      self.class.option "--new-name", "NEW_NAME", "new name for the resource" if self.class.identifier? :name
    end

    def request_params
      params = method_options
      params['name'] = new_name if self.class.identifier? :name
      params['id'] = get_identifier[0]
      params
    end

    def self.apipie_options options={}
      super({:without => declared_identifiers}.merge(options))
    end

  end


  class DeleteCommand < HammerCLI::Apipie::WriteCommand

    identifiers :id, :name

    def request_params
      {'id' => get_identifier[0]}
    end

    def self.apipie_options options={}
      super({:without => declared_identifiers}.merge(options))
    end

  end


end
