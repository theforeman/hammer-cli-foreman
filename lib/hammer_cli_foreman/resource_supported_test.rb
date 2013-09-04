module HammerCLIForeman

  module ResourceSupportedTest

    def execute
      if resource_supported?
        super
      else
        output.print_error "The server does not support such operation."
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


