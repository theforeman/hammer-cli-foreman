module HammerCLIForeman::Output
  module Formatters

    class OSNameFormatter < HammerCLI::Output::Formatters::FieldFormatter
      def format(os)
        name = "%s %s" % [os[:name], os[:major]]
        name += ".%s" % os[:minor] unless os[:minor].nil?
        name
      end
    end

    class ServerFormatter < HammerCLI::Output::Formatters::FieldFormatter
      def format(server)
        "%s (%s)" % [server[:name], server[:url]]
      end
    end

    DEFAULT_FORMATTERS = HammerCLI::Output::Formatters::DEFAULT_FORMATTERS
    DEFAULT_FORMATTERS.register_formatter(:OSName, OSNameFormatter.new)
    DEFAULT_FORMATTERS.register_formatter(:Server, ServerFormatter.new)

  end
end
