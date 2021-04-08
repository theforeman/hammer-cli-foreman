module HammerCLIForeman
  module Hosts
    module CommonUpdateOptions

      def self.included(base)
        base.option "--owner", "OWNER_LOGIN", _("Login of the owner"),
          :attribute_name => :option_user_login
        base.option "--owner-id", "OWNER_ID", _("ID of the owner"),
          :attribute_name => :option_owner_id

        base.option "--root-password", "ROOT_PW",
          _("Required if host is managed and value is not inherited from host group or default password in settings")

        base.option "--ask-root-password", "ASK_ROOT_PW", " ",
          :format => HammerCLI::Options::Normalizers::Bool.new

        base.option '--puppet-proxy', 'PUPPET_PROXY_NAME', '',
                    referenced_resource: 'puppet_proxy',
                    aliased_resource: 'puppet_proxy'
        base.option '--puppet-ca-proxy', 'PUPPET_CA_PROXY_NAME', '',
                    referenced_resource: 'puppet_ca_proxy',
                    aliased_resource: 'puppet_ca_proxy'
        base.option_family(
          format: HammerCLI::Options::Normalizers::List.new,
          aliased_resource: 'puppet-class',
          description: 'Names/Ids of associated puppet classes'
        ) do
          parent '--puppet-class-ids', 'PUPPET_CLASS_IDS', '',
                 attribute_name: :option_puppetclass_ids
          child '--puppet-classes', 'PUPPET_CLASS_NAMES', '',
                 attribute_name: :option_puppetclass_names
        end
        bme_options = {}
        bme_options[:default] = 'true' if base.action.to_sym == :create

        bme_options[:format] = HammerCLI::Options::Normalizers::Bool.new
        base.option "--overwrite", "OVERWRITE", " ",  bme_options

        base.option "--parameters", "PARAMS", _("Replaces with new host parameters"),
          :format => HammerCLI::Options::Normalizers::KeyValueList.new

        host_params = base.resource.action(base.action).params
                          .find { |p| p.name == 'host' }.params
                          .find { |p| p.name == 'host_parameters_attributes' }
        base.option "--typed-parameters", "TYPED_PARAMS", _("Replaces with new host parameters (with type support)"),
          :format => HammerCLI::Options::Normalizers::ListNested.new(host_params.params)
        base.option "--compute-attributes", "COMPUTE_ATTRS", _("Compute resource attributes"),
          :format => HammerCLI::Options::Normalizers::KeyValueList.new
        base.option "--volume", "VOLUME", _("Volume parameters"), :multivalued => true,
          :format => HammerCLI::Options::Normalizers::KeyValueList.new
        base.option "--interface", "INTERFACE", _("Interface parameters"), :multivalued => true,
          :format => HammerCLI::Options::Normalizers::KeyValueList.new

        base.build_options :without => [
              # - temporarily disabled params that will be removed from the api ------------------
              :capabilities, :flavour_ref, :image_ref, :start,
              :network, :cpus, :memory, :provider, :type, :tenant_id, :image_id,
              # ----------------------------------------------------------------------------------
              :puppet_class_ids, :host_parameters_attributes, :interfaces_attributes, :root_pass]
      end

      def self.ask_password
        prompt = _("Enter the root password for the host:") + " "
        HammerCLI.interactive_output.ask(prompt) { |q| q.echo = false }
      end

      def request_params
        params = super
        owner_id = owner_id(option_user_login, params['host']['owner_type'])
        params['host']['owner_id'] ||= owner_id unless owner_id.nil?

        puppet_proxy_id = proxy_id(option_puppet_proxy)
        params['host']['puppet_proxy_id'] ||= puppet_proxy_id unless puppet_proxy_id.nil?

        puppet_ca_proxy_id = proxy_id(option_puppet_ca_proxy)
        params['host']['puppet_ca_proxy_id'] ||= puppet_ca_proxy_id unless puppet_ca_proxy_id.nil?

        if action == :create
          params['host']['build'] = true if option_build.nil?
          params['host']['managed'] = true if option_managed.nil?
          params['host']['enabled'] = true if option_enabled.nil?
        end
        params['host']['overwrite'] = option_overwrite unless option_overwrite.nil?

        params['host']['host_parameters_attributes'] = parameter_attributes unless option_parameters.nil?
        params['host']['host_parameters_attributes'] ||= option_typed_parameters unless option_typed_parameters.nil?

        if option_compute_attributes && !option_compute_attributes.empty?
          params['host']['compute_attributes'] = host_compute_attrs(option_compute_attributes)
        end

        if action == :update
          unless option_volume_list.empty?
            params['host']['compute_attributes'] ||= {}
            params['host']['compute_attributes']['volumes_attributes'] = nested_attributes(option_volume_list)
          end
          params['host']['interfaces_attributes'] = interfaces_attributes unless option_interface_list.empty?
          if options['option_new_location_id']
            params['host']['location_id'] = options['option_new_location_id']
          else
            params['host'].delete('location_id')
          end
          if options['option_new_organization_id']
            params['host']['organization_id'] = options['option_new_organization_id']
          else
            params['host'].delete('organization_id')
          end
        else
          params['host']['compute_attributes'] ||= {}
          params['host']['compute_attributes']['volumes_attributes'] = nested_attributes(option_volume_list)
          params['host']['interfaces_attributes'] = interfaces_attributes
        end
        if options['option_image_id']
          if params['host']['compute_resource_id']
            compute_resource_id = params['host']['compute_resource_id']
          elsif params['id']
            compute_resource_id = ::HammerCLIForeman::ComputeResources.get_host_compute_resource_id(params['id'])
          elsif params['host']['hostgroup_id']
            compute_resource_id = ::HammerCLIForeman::ComputeResources.get_hostgroup_compute_resource_id(params['host']['hostgroup_id'])
          end
          raise ArgumentError, "Missing argument for 'compute_resource'" if compute_resource_id.nil?
          image_uuid =  ::HammerCLIForeman::ComputeResources.get_image_uuid(compute_resource_id, options["option_image_id"])
          params['host']['compute_attributes'] ||= {}
          params['host']['compute_attributes']['image_id'] = image_uuid
        end
        params['host']['root_pass'] = option_root_password unless option_root_password.nil?

        if option_ask_root_password
          params['host']['root_pass'] = HammerCLIForeman::Hosts::CommonUpdateOptions::ask_password
        end

        params
      end

      private

     
      def owner_id(name, type)
        return unless name
        return resolver.usergroup_id('option_name' => name) if type == 'Usergroup'

        resolver.user_id('option_login' => name)
      end
      
      def proxy_id(name)
        resolver.smart_proxy_id('option_name' => name) if name
      end

      def subnet_id(name)
        resolver.subnet_id('option_name' => name) if name
      end

      def domain_id(name)
        resolver.domain_id('option_name' => name) if name
      end

      def parameter_attributes
        return [] unless option_parameters
        option_parameters.collect do |key, value|
          if value.is_a? String
            {"name"=>key, "value"=>value}
          else
            {"name"=>key, "value"=>value.inspect}
          end
        end
      end

      def host_compute_attrs(attrs)
        attrs['display'] = {} unless attrs['display_type'].nil? && attrs['keyboard_layout'].nil?
        attrs['display']['type'] = attrs.delete('display_type') unless attrs['display_type'].nil?
        attrs['display']['keyboard_layout'] = attrs.delete('keyboard_layout') unless attrs['keyboard_layout'].nil?
        attrs
      end

      def nested_attributes(attrs)
        return {} unless attrs

        nested_hash = {}
        attrs.each_with_index do |attr, i|
          nested_hash[i.to_s] = attr
        end
        nested_hash
      end

      def interfaces_attributes
        return [] if option_interface_list.empty?

        # move each attribute starting with "compute_" to compute_attributes
        option_interface_list.collect do |nic|
          compute_attributes = {}
          nic.keys.each do |key|
            if key.start_with? 'compute_'
              compute_attributes[key.gsub('compute_', '')] = nic.delete(key)
            end
          end
          subnet_name = nic.delete('subnet')
          nic['subnet_id'] ||= subnet_id(subnet_name) if subnet_name
          domain_name = nic.delete('domain')
          nic['domain_id'] ||= domain_id(domain_name) if domain_name
          nic['compute_attributes'] = compute_attributes unless compute_attributes.empty?
          nic
        end
      end
    end
  end
end
