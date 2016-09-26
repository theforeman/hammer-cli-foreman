module HammerCLIForeman

  class Audit < HammerCLIForeman::Command

    resource :audits

    class ListCommand < HammerCLIForeman::ListCommand

      def request_params
        params = super
        params['search'] ||= 'time >= "1 month ago"'
        params
      end

      def self.included(base)
        base.extend_help do |h|
          h.section(_('Override audit record pagination')) do
            h.text(_('Audit records for past one month are returned by default. This behavior can be changed by passing --search option.'))
          end
        end
      end

      output do
        field :id, _("Id")
        field :created_at, _("At"), Fields::Date
        field :remote_address, _("IP")
        field nil, _("User"), Fields::SingleReference, :key => :user
        field :action, _("Action")
        field :auditable_type, _("Audit type")
        field nil, _("Audit record"), Fields::SingleReference, :key => :auditable
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      def extend_data(audit)
        audit["changes"] = audit["audited_changes"].map do |attribute, change|
          if change.is_a?(Array)
            {
              'attribute' => attribute,
              'old' => (change[0] ? change[0] : change[0].to_s),
              'new' => change[1]
            }
          elsif !change.nil?
            {
              'attribute' => attribute,
              'value' => change
            }
          end
        end.compact
        audit
      end

      output ListCommand.output_definition do
        collection :changes, _("Audited changes") do
          field :attribute, _("Attribute")
          field :value, _("Value"), Fields::Field, :hide_blank => true
          field :old, _("Old"), Fields::LongText, :hide_blank => true
          field :new, _("New"), Fields::LongText, :hide_blank => true
        end
      end

      build_options
    end

    autoload_subcommands
  end

end
