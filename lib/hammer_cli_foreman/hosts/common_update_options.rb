module HammerCLIForeman
  module Hosts
    module CommonUpdateOptions

      def self.included(base)
        base.option "--owner", "OWNER_LOGIN", _("Login of the owner"),
          :attribute_name => :option_user_login
        base.option "--owner-id", "OWNER_ID", _("ID of the owner"),
          :attribute_name => :option_user_id

        base.option ["--root-password", "--root-pass"], "ROOT_PW",
          _("Required if host is managed and value is not inherited from host group or default password in settings"),
          :deprecated => { '--root-pass' => _("Use --root-password instead") }

        base.option "--ask-root-password", "ASK_ROOT_PW", " ",
          :format => HammerCLI::Options::Normalizers::Bool.new

        base.option "--puppet-proxy", "PUPPET_PROXY_NAME", ""
        base.option "--puppet-ca-proxy", "PUPPET_CA_PROXY_NAME", ""
        base.option "--puppet-class-ids", "PUPPET_CLASS_IDS", "",
          :format => HammerCLI::Options::Normalizers::List.new,
          :attribute_name => :option_puppetclass_ids
        base.option "--puppet-classes", "PUPPET_CLASS_NAMES", "",
          :format => HammerCLI::Options::Normalizers::List.new

        bme_options = {}
        bme_options[:default] = 'true' if base.action.to_sym == :create

        bme_options[:format] = HammerCLI::Options::Normalizers::Bool.new
        base.option "--managed", "MANAGED", " ", bme_options
        bme_options[:format] = HammerCLI::Options::Normalizers::Bool.new
        base.option "--build", "BUILD", " ", bme_options
        bme_options[:format] = HammerCLI::Options::Normalizers::Bool.new
        base.option "--enabled", "ENABLED", " ",  bme_options
        bme_options[:format] = HammerCLI::Options::Normalizers::Bool.new
        base.option "--overwrite", "OVERWRITE", " ",  bme_options

        base.option "--parameters", "PARAMS", _("Host parameters."),
          :format => HammerCLI::Options::Normalizers::KeyValueList.new
        base.option "--compute-attributes", "COMPUTE_ATTRS", _("Compute resource attributes."),
          :format => HammerCLI::Options::Normalizers::KeyValueList.new
        base.option "--volume", "VOLUME", _("Volume parameters"), :multivalued => true,
          :format => HammerCLI::Options::Normalizers::KeyValueList.new
        base.option "--interface", "INTERFACE", _("Interface parameters."), :multivalued => true,
          :format => HammerCLI::Options::Normalizers::KeyValueList.new
        base.option "--provision-method", "METHOD", " ",
          :format => HammerCLI::Options::Normalizers::Enum.new(['build', 'image'])

        base.build_options :without => [
              # - temporarily disabled params that will be removed from the api ------------------
              :provision_method, :capabilities, :flavour_ref, :image_ref, :start,
              :network, :cpus, :memory, :provider, :type, :tenant_id, :image_id,
              # ----------------------------------------------------------------------------------
              :puppet_class_ids, :host_parameters_attributes, :interfaces_attributes, :root_pass]
      end

      def self.ask_password
        prompt = _("Enter the root password for the host:") + " "
        ask(prompt) {|q| q.echo = false}
      end

      def request_params
        params = super

        owner_id = get_resource_id(HammerCLIForeman.foreman_resource(:users), :required => false, :scoped => true)
        params['host']['owner_id'] ||= owner_id unless owner_id.nil?

        puppet_proxy_id = proxy_id(option_puppet_proxy)
        params['host']['puppet_proxy_id'] ||= puppet_proxy_id unless puppet_proxy_id.nil?

        puppet_ca_proxy_id = proxy_id(option_puppet_ca_proxy)
        params['host']['puppet_ca_proxy_id'] ||= puppet_ca_proxy_id unless puppet_ca_proxy_id.nil?

        puppetclass_ids = option_puppetclass_ids || puppet_class_ids(option_puppet_classes)
        params['host']['puppetclass_ids'] = puppetclass_ids unless puppetclass_ids.nil?

        params['host']['build'] = option_build unless option_build.nil?
        params['host']['managed'] = option_managed unless option_managed.nil?
        params['host']['enabled'] = option_enabled unless option_enabled.nil?
        params['host']['overwrite'] = option_overwrite unless option_overwrite.nil?

        params['host']['host_parameters_attributes'] = parameter_attributes
        params['host']['compute_attributes'] = option_compute_attributes || {}
        params['host']['compute_attributes']['volumes_attributes'] = nested_attributes(option_volume_list)
        params['host']['interfaces_attributes'] = interfaces_attributes

        params['host']['root_pass'] = option_root_password unless option_root_password.nil?

        if option_ask_root_password
          params['host']['root_pass'] = HammerCLIForeman::Hosts::CommonUpdateOptions::ask_password
        end

        params
      end

      private

      def proxy_id(name)
        resolver.smart_proxy_id('option_name' => name) if name
      end

      def puppet_class_ids(names)
        resolver.puppetclass_ids('option_names' => names) if names
      end

      def subnet_id(name)
        resolver.subnet_id('option_name' => name) if name
      end

      def domain_id(name)
        resolver.domain_id('option_name' => name) if name
      end

      def parameter_attributes
        return {} unless option_parameters
        option_parameters.collect do |key, value|
          if value.is_a? String
            {"name"=>key, "value"=>value}
          else
            {"name"=>key, "value"=>value.inspect}
          end
        end
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
        return {} if option_interface_list.empty?

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
