module HammerCLIForeman::Output
  module Formatters
    class ReferenceFormatter < HammerCLI::Output::Formatters::FieldFormatter
      def tags
        [:flat]
      end

      # Parameters:
      # :display_field_key - key where the formmatter will look for the main field to display, default is :name
      # :details - detail fields to be displayed
      #  example format:
      #  :details => [
      #    { :label => _('Type'), :key => :provider_friendly_name, :structured_label => _('Type') },
      #    { :label => _('Id'), :key => :id }
      #  ]
      def format(data, field_params={})
        return "" if data.nil?

        name = get_value(data, field_params[:display_field_key] || :name)
        context = field_params[:context] || {}

        details = format_details(data, field_params[:details] || [], context[:show_ids])
        if details.empty?
          "#{name}" if name
        else
          "#{name} (#{details.join(', ')})" if name
        end
      end

      protected
      def format_details(data, details, show_ids)
        details = [details] unless details.is_a?(Array)

        details.map do |detail|
          if detail.is_a?(Hash)
            next if detail[:id] && !show_ids
            if detail[:label]
              "#{detail[:label]}: #{get_value(data, detail[:key])}"
            else
              get_value(data, detail[:key])
            end
          else
            get_value(data, detail)
          end
        end.compact
      end

      def get_value(data, key)
        data[key] || data[key.to_s]
      end
    end

    class StructuredReferenceFormatter < HammerCLI::Output::Formatters::FieldFormatter
      def tags
        [:data]
      end

      # Parameters:
      # :display_field_key - key where the formmatter will look for the main field to display, default is :name
      # :details - detail fields to be displayed
      #  example format:
      #  :details => [
      #    { :label => _('Type'), :key => :provider_friendly_name, :structured_label => _('Type') },
      #    { :label => _('Id'), :key => :id }
      #  ]
      def format(data, field_params={})
        return  {} if data.nil? || data == ""

        display_field_key = field_params[:display_field_key] || :name

        # TODO: hardcoded name
        formatted = {
          _('Name') => get_value(data, display_field_key)
        }

        details = field_params[:details]
        details = [details] unless details.is_a?(Array)

        details.map do |detail|
          if detail.is_a?(Hash)
            label = detail[:structured_label]
            label = detail[:label].capitalize if !label && detail[:label]
            if label
              formatted[label] = get_value(data, detail[:key])
            end
          end
        end
        formatted
      end

      protected
      def get_value(data, key)
        data[key] || data[key.to_s]
      end
    end

    HammerCLI::Output::Output.register_formatter(ReferenceFormatter.new, :SingleReference)
    HammerCLI::Output::Output.register_formatter(StructuredReferenceFormatter.new, :SingleReference)

    HammerCLI::Output::Output.register_formatter(ReferenceFormatter.new, :Reference)
    HammerCLI::Output::Output.register_formatter(StructuredReferenceFormatter.new, :Reference)
    HammerCLI::Output::Output.register_formatter(ReferenceFormatter.new, :Template)
    HammerCLI::Output::Output.register_formatter(StructuredReferenceFormatter.new, :Template)
  end
end

