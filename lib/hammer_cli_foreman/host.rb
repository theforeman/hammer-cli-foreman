require 'hammer_cli_foreman/fact'
require 'hammer_cli_foreman/report'
require 'hammer_cli_foreman/puppet_class'
require 'hammer_cli_foreman/smart_class_parameter'
require 'hammer_cli_foreman/smart_variable'
require 'hammer_cli_foreman/interface'

require 'highline/import'

module HammerCLIForeman

  module CommonHostUpdateOptions

    def self.included(base)
      base.option "--owner", "OWNER_LOGIN", _("Login of the owner"),
        :attribute_name => :option_user_login
      base.option "--owner-id", "OWNER_ID", _("ID of the owner"),
        :attribute_name => :option_user_id

      base.option "--root-password", "ROOT_PW", " "
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
            :puppet_class_ids, :host_parameters_attributes, :interfaces_attributes]
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

      # check primary and provision interfaces, only for create
      check_mandatory_interfaces(params['host']['interfaces_attributes']) if params['id'].nil?

      params['host']['root_pass'] = option_root_password unless option_root_password.nil?

      if option_ask_root_password
        params['host']['root_pass'] = HammerCLIForeman::CommonHostUpdateOptions::ask_password
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
        nic['compute_attributes'] = compute_attributes unless compute_attributes.empty?
        nic
      end
    end

    def check_mandatory_interfaces(nics)
      unless nics.any? { |key, nic| nic['primary'] == 'true' }
        signal_usage_error _('At least one interface must be set as primary')
      end
      unless nics.any? { |key, nic| nic['provision'] == 'true' }
        signal_usage_error _('At least one interface must be set as provision')
      end
    end

  end


  class Host < HammerCLIForeman::Command

    resource :hosts

    class ListCommand < HammerCLIForeman::ListCommand
      # FIXME: list compute resource (model)
      output do
        field :id, _("Id")
        field :name, _("Name")
        field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
        field nil, _("Host Group"), Fields::SingleReference, :key => :hostgroup
        field :ip, _("IP")
        field :mac, _("MAC")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      def extend_data(host)
        host['compute_resource_name'] ||= _('Bare Metal')
        host['image_file'] = nil if host['image_file'].empty?
        host['interfaces'] = host['interfaces'].map do |nic|
          nic['_type'] = HammerCLIForeman::Interface.format_type(nic)
          nic
        end if host['interfaces']

        # FIXME: temporary fetching parameters until the api gets fixed.
        # Noramlly they should come in the host's json.
        # http://projects.theforeman.org/issues/5820
        host['parameters'] = get_parameters(host["id"])

        host
      end

      def get_parameters(host_id)
        params = HammerCLIForeman.foreman_resource!(:parameters).call(:index, :host_id => host_id)
        HammerCLIForeman.collection_to_common_format(params)
      end


      output do
        field :id, _("Id")
        field :uuid, _("UUID"), Fields::Field, :hide_blank => true
        field :name, _("Name")
        field nil, _("Organization"), Fields::SingleReference, :key => :organization, :hide_blank => true
        field nil, _("Location"), Fields::SingleReference, :key => :location, :hide_blank => true
        field nil, _("Host Group"), Fields::SingleReference, :key => :hostgroup
        field nil, _("Compute Resource"), Fields::SingleReference, :key => :compute_resource
        field nil, _("Compute Profile"), Fields::SingleReference, :key => :compute_profile, :hide_blank => true
        field nil, _("Environment"), Fields::SingleReference, :key => :environment
        field :puppet_ca_proxy_id, _("Puppet CA Id")
        field :puppet_proxy_id, _("Puppet Master Id")
        field :certname, _("Cert name")
        field :managed, _("Managed"), Fields::Boolean

        field :installed_at, _("Installed at"), Fields::Date
        field :last_report, _("Last report"), Fields::Date

        label _("Network") do
          field :ip, _("IP")
          field :mac, _("MAC")
          field nil, _("Subnet"), Fields::SingleReference, :key => :subnet
          field nil, _("Domain"), Fields::SingleReference, :key => :domain
          field nil, _("Service provider"), Fields::Label, :hide_blank => true do
            field :sp_name, _("SP Name"), Fields::Field, :hide_blank => true
            field :sp_ip, _("SP IP"), Fields::Field, :hide_blank => true
            field :sp_mac, _("SP MAC"), Fields::Field, :hide_blank => true
            field nil, _("SP Subnet"), Fields::SingleReference, :key => :sp_subnet, :hide_blank => true
          end
        end

        collection :interfaces, _("Network interfaces") do
          field :id, _('Id')
          field :identifier, _('Identifier')
          field :_type, _('Type')
          field :mac, _('MAC address')
          field :ip, _('IP address')
          field :fqdn, _('FQDN')
        end

        label _("Operating system") do
          field nil, _("Architecture"), Fields::SingleReference, :key => :architecture
          field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
          # provision_method
          # for network based
          field :build, _("Build"), Fields::Boolean
          field nil, _("Medium"), Fields::SingleReference, :key => :medium
          field nil, _("Partition Table"), Fields::SingleReference, :key => :ptable
          field :disk, _("Custom partition table"), Fields::LongText
          # image
          # for image based
          field nil, _("Image"), Fields::SingleReference, :key => :image, :hide_blank => true
          field :image_file, _("Image file"), Fields::Field, :hide_blank => true
          field :use_image, _("Use image"), Fields::Boolean, :hide_blank => true
        end

        HammerCLIForeman::References.parameters(self)

        # additional info
        label _("Additional info") do
          field :owner_id, _("Owner Id")
          field :owner_type, _("Owner Type")
          field :enabled, _("Enabled"), Fields::Boolean
          field nil, _("Model"), Fields::SingleReference, :key => :model, :hide_blank => true
          field :comment, _("Comment"), Fields::LongText
        end
      end

      build_options
    end


    class StatusCommand < HammerCLIForeman::SingleResourceCommand
      command_name "status"
      action :status

      output do
        field :status, _("Status")
        field :power, _("Power")
      end

      def send_request
        {
          :status => get_status,
          :power => get_power_status
        }
      end

      def get_status
        params = {
          'id' => get_identifier,
        }
        status = resource.call(:status, params)
        status["status"]
      end

      def get_power_status
        params = {
          'id' => get_identifier,
          'power_action' => :state
        }
        status = resource.call(:power, params)
        status["power"]
      end

      build_options
    end


    class PuppetRunCommand < HammerCLIForeman::SingleResourceCommand
      command_name "puppetrun"
      action :puppetrun

      def print_data(records)
        print_message _('Puppet run triggered')
      end

      build_options
    end


    class FactsCommand < HammerCLIForeman::AssociatedResourceListCommand
      command_name "facts"
      resource :fact_values, :index
      parent_resource :hosts

      output do
        field :fact, _("Fact")
        field :value, _("Value")
      end

      def send_request
        HammerCLIForeman::Fact::ListCommand.unhash_facts(super)
      end

      build_options
    end


    class PuppetClassesCommand < HammerCLIForeman::ListCommand
      command_name "puppet-classes"
      resource :puppetclasses

      output HammerCLIForeman::PuppetClass::ListCommand.output_definition

      def send_request
        HammerCLIForeman::PuppetClass::ListCommand.unhash_classes(super)
      end

      build_options do |o|
        o.without(:hostgroup_id, :environment_id)
        o.expand.only(:hosts)
      end
    end


    class ReportsCommand < HammerCLIForeman::AssociatedResourceListCommand
      command_name "reports"
      resource :reports, :index
      parent_resource :hosts

      output HammerCLIForeman::Report::ListCommand.output_definition

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Host created")
      failure_message _("Could not create the host")

      include HammerCLIForeman::CommonHostUpdateOptions

      def validate_options
        super
        unless validator.any(:option_hostgroup_id, :option_hostgroup_name).exist?
          if option_managed
            validator.all(:option_environment_id, :option_architecture_id, :option_domain_id,
                          :option_puppet_proxy_id, :option_operatingsystem_id,
                          :option_ptable_id).required
          else
            # unmanaged host only requires environment
            validator.option(:option_environment_id).required
          end
        end
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Host updated")
      failure_message _("Could not update the host")

      include HammerCLIForeman::CommonHostUpdateOptions
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Host deleted")
      failure_message _("Could not delete the host")

      build_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for a host.")

      success_message_for :update, _("Host parameter updated")
      success_message_for :create, _("New host parameter created")
      failure_message _("Could not set host parameter")

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end

      build_options
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for a host.")

      success_message _("Host parameter deleted")

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end

      build_options
    end


    class StartCommand < HammerCLIForeman::SingleResourceCommand
      action :power

      command_name "start"
      desc _("Power a host on")
      success_message _("The host is starting.")

      def option_power_action
        :start
      end

      def request_params
        params = super
        params['id'] = get_identifier
        params
      end

      build_options :without => :power_action
    end


    class StopCommand < HammerCLIForeman::SingleResourceCommand
      option '--force', :flag, _("Force turning off a host")

      action :power

      command_name "stop"
      desc _("Power a host off")

      def option_power_action
        if option_force?
          :cycle
        else
          :stop
        end
      end

      def success_message
        if option_force?
          _("Power off forced.")
        else
          _("Powering the host off.")
        end
      end

      def request_params
        params = super
        params['id'] = get_identifier
        params
      end

      build_options :without => :power_action
    end

    class RebootCommand < HammerCLIForeman::SingleResourceCommand
      action :power

      command_name "reboot"
      desc _("Reboot a host")
      success_message _("Host reboot started.")

      def option_power_action
        :soft
      end

      def request_params
        params = super
        params['id'] = get_identifier
        params
      end

      build_options :without => :power_action
    end

    class SCParamsCommand < HammerCLIForeman::SmartClassParametersList
      build_options_for :hosts

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end
    end

    class SmartVariablesCommand < HammerCLIForeman::SmartVariablesList
      build_options_for :hosts

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end
    end

    autoload_subcommands

    subcommand 'interface', HammerCLIForeman::Interface.desc, HammerCLIForeman::Interface
  end

end
