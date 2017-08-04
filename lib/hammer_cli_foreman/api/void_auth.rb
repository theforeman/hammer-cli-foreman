require 'highline/import'

module HammerCLIForeman
  module Api
    class VoidAuth < ApipieBindings::Authenticators::Base
      def initialize(message)
        @message = message
      end

      def status
        @message
      end
    end
  end
end
