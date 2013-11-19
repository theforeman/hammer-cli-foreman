module HammerCLIForeman

  class OperationNotSupportedError < StandardError; end

  module ResourceSupportedTest

    def execute
      if resource_supported?
        super
      else
        raise OperationNotSupportedError, "The server does not support such operation."
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


