module HammerCLIForeman
  module OptionSources
    class UserParams
      def initialize(command)
        @command = command
      end

      def get_options(defined_options, result)
        org_id = organization_id(result[option_name(:default_organization)])
        result[option_name(:default_organization_id)] ||= org_id unless org_id.nil?
        loc_id = location_id(result[option_name(:default_location)])
        result[option_name(:default_location_id)] ||= loc_id unless loc_id.nil?

        if @command.action == :update
          if result[option_name(:password)] || result[option_name(:ask_password)]

            if current_logged_user["id"].to_s == result[option_name(:id)].to_s
              curr_passwd = HammerCLIForeman.foreman_api_connection.authenticator.password(true)
              result[option_name(:current_password)] = curr_passwd unless curr_passwd.nil?
              unless result[option_name(:current_password)]
                result[option_name(:current_password)] = ask_password(:current)
              end
            end
          end
        end

        if result[option_name(:ask_password)]
          result[option_name(:password)] = ask_password(:new)
        end

        result
      end

      private

      def option_name(opt_name)
        HammerCLI.option_accessor_name(opt_name)
      end

      def ask_password(type)
        if type == :current
          prompt = _("Enter user's current password:") + " "
        elsif type == :new
          prompt = _("Enter user's new password:") + " "
        end
        HammerCLI.interactive_output.ask(prompt) { |q| q.echo = false }
      end

      def organization_id(name)
        @command.resolver.organization_id('option_name' => name) if name
      end

      def location_id(name)
        @command.resolver.location_id('option_name' => name) if name
      end

      def current_logged_user
        HammerCLIForeman.foreman_api_connection.resource(:users).call(:show, :id => HammerCLIForeman.foreman_api_connection.authenticator.user(true))
      end
    end
  end
end
