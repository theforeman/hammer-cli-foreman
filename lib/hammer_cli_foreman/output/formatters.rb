module HammerCLIForeman::Output
  module Formatters

    class OSNameFormatter < HammerCLI::Output::Formatters::FieldFormatter

      def tags
        [:flat]
      end

      def format(os)
        name = "%s %s" % [os[:name], os[:major]]
        name += ".%s" % os[:minor] unless (!os.has_key?(:minor) || os[:minor].empty?)
        name
      end
    end

    class ServerFormatter < HammerCLI::Output::Formatters::FieldFormatter
      
      def tags
        [:flat]
      end

      def format(server)
        "%s (%s)" % [server[:name], server[:url]]
      end
    end

    HammerCLI::Output::Output.register_formatter(OSNameFormatter.new, :OSName)
    HammerCLI::Output::Output.register_formatter(ServerFormatter.new, :Server)

  end
end
