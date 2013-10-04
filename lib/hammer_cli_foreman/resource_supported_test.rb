module HammerCLIForeman

  module ResourceSupportedTest

    def execute
      if resource_supported?
        super
      else
        error = "The server does not support such operation."
        HammerCLI::Output::Output.print_error error, nil, context, :adapter => adapter
        1
      end
    end

    def resource_supported?
      resource.call(:index)
      true
    rescue RestClient::ResourceNotFound => e
      false
    end

  end

end


