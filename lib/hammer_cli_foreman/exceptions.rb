module HammerCLIForeman

  class OperationNotSupportedError < StandardError; end

  # Resolver exceptions
  class ResolverError < StandardError; end
  class MissingSeachOptions < ResolverError; end

end


