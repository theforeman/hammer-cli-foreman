module HammerCLIForeman

  class OperationNotSupportedError < StandardError; end

  # Resolver exceptions
  class ResolverError < StandardError

    attr_reader :resource

    def initialize(msg, resource)
      @resource = resource
      super(msg)
    end
  end

  class MissingSearchOptions < ResolverError; end

end


