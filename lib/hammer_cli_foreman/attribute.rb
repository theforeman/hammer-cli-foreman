require 'hammer_cli_foreman/image'
require 'hammer_cli_foreman/compute_resources'

module HammerCLIForeman
  class Attribute < HammerCLIForeman::Command
    resource :compute_attributes

    def new_element_id
      Time.now.to_i.to_s
    end

    def self.get_params(options)
      params = {}
      params['compute_attribute'] = {}
      profile = HammerCLIForeman.record_to_common_format(
          HammerCLIForeman.foreman_resource(:compute_profiles).call(:show, 'id' => options['option_compute_profile_id'] )
      )
      HammerCLIForeman.foreman_resource(:compute_resources).call(:show, 'id' => options['option_compute_resource_id'] )
      params['compute_attribute'] = profile['compute_attributes'].select { |hash| hash['compute_resource_id'] == options['option_compute_resource_id']}[0] || {}
      params
    end

    class Create < HammerCLIForeman::CreateCommand
        desc _('Create compute profile set of values.')

      option '--compute-attributes', 'COMPUTE_ATTRS', _('Compute resource attributes'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--interface', 'INTERFACE', _('Interface parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :multivalued => true
      option '--volume', 'VOLUME', _('Volume parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :multivalued => true

      extend_help do |h|
        ::HammerCLIForeman::ComputeResources.extend_help(h, :all)
      end

      validate_options do
        any(:option_compute_profile_id, :option_compute_profile_name ).required
        any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = super
        params['compute_attribute']['vm_attrs'] = option_compute_attributes || {}
        if option_interface
          params['compute_attribute']['vm_attrs']['interfaces_attributes'] = {new_element_id => option_interface}
        end
        if option_volume
            params['compute_attribute']['vm_attrs']['volumes_attributes'] = {new_element_id => option_volume}
        end
        params
      end

      success_message _('Compute profile attributes are set.')
      failure_message _('Could not set the compute profile attributes')
      build_options
    end

    class Update < HammerCLIForeman::UpdateCommand
      desc _('Update compute profile values.')

      option '--compute-attributes', 'COMPUTE_ATTRS', _('Compute resource attributes, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--interface', 'INTERFACE', _('Interface parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :multivalued => true
      option '--volume', 'VOLUME', _('Volume parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :multivalued => true

      extend_help do |h|
        ::HammerCLIForeman::ComputeResources.extend_help(h, :all)
      end

      validate_options do
        any(:option_compute_profile_id, :option_compute_profile_name ).required
        any(:option_compute_resource_id, :option_compute_resource_name).required
        any(:option_interface, :option_volume, :option_compute_attributes).required
      end

      def request_params
        params = HammerCLIForeman::Attribute.get_params(options)
        params['id'] =  params['compute_attribute']['id']
        params['compute_attribute']['vm_attrs'] = option_compute_attributes if option_compute_attributes
        params['compute_attribute']['vm_attrs']['interfaces_attributes'] = option_interface if option_interface
        params['compute_attribute']['vm_attrs']['volumes_attributes'] = option_compute_attributes if option_volume
        params
      end
      success_message _('Compute profile attributes updated.')
      failure_message _('Could not update the compute profile attributes')

      build_options :without => :id
    end
    # Using the Update command because adding a new interface is done by modifying existing compute_attribute
    class AddInterface < HammerCLIForeman::UpdateCommand
      command_name 'add-interface'
      desc _('Add interface for Compute Profile.')
      option '--set-values', 'SET_VALUES', _('Interface parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :required => true

      extend_help do |h|
        ::HammerCLIForeman::ComputeResources.extend_help(h, :all)
      end

      def validate_options
        super
        validator.any(:option_compute_profile_id,:option_compute_profile_name).required
        validator.any(:option_compute_resource_id,:option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::Attribute.get_params(options)
        interface_attr =  params['compute_attribute']['vm_attrs']['interfaces_attributes'] || {}
        params['id'] = params['compute_attribute']['id']
        params['compute_attribute']['vm_attrs']['interfaces_attributes'] = interface_attr.merge({new_element_id => option_set_values})
        params
      end

      success_message _('Interface was created.')
      failure_message _('Could not create interface')

      build_options :without => :id
    end

    class UpdateInterface < HammerCLIForeman::UpdateCommand
      command_name 'update-interface'

      desc _('Update compute profile interface.')

      option '--set-values', 'SET_VALUES', _('Interface parameters, should be comma separated list of values'),
             :required => true,
             :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--interface-id', 'INTERFACE_ID', _('Interface id'),
             :required => true,
             :format => HammerCLI::Options::Normalizers::Number.new

      extend_help do |h|
        ::HammerCLIForeman::ComputeResources.extend_help(h, :all)
      end

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::Attribute.get_params(options)
        interface_attr =  params['compute_attribute']['vm_attrs']['interfaces_attributes'] || {}
        params['id'] = params['compute_attribute']['id']
        params['compute_attribute']['vm_attrs']['interfaces_attributes'] = interface_attr.merge({option_interface_id => option_set_values})
        params
      end
      success_message _('Interface was updated.')
      failure_message _('Could not update interface')
      build_options :without => :id
    end

    # Using the Update command because removing an interface is done by modifying existing compute_attribute
    class RemoveInterface < HammerCLIForeman::UpdateCommand
      command_name 'remove-interface'
      desc _('Remove compute profile interface.')
      option '--interface-id', 'INTERFACE ID', _('Interface id'),
             :format => HammerCLI::Options::Normalizers::Number.new , :required => true

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::Attribute.get_params(options)
        params['id'] = params['compute_attribute']['id']
        if params['compute_attribute']['vm_attrs']['interfaces_attributes'].has_key?(option_interface_id.to_s)
          params['compute_attribute']['vm_attrs']['interfaces_attributes'].delete(option_interface_id.to_s)
        else
          signal_usage_error _('unknown interface id')
        end
        params
      end
      success_message _('Interface was removed.')
      failure_message _('Could not remove interface')
      build_options :without => :id
    end

    # Using the Update command because adding a new volume is done by modifying existing compute_attribute
    class AddVolume < HammerCLIForeman::UpdateCommand
      command_name 'add-volume'
      desc _('Add volume for Compute Profile.')

      option '--set-values', 'VOLUME', _('Volume parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :required => true

      extend_help do |h|
        ::HammerCLIForeman::ComputeResources.extend_help(h, :all)
      end

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params

        params = HammerCLIForeman::Attribute.get_params(options)
        volume_attr =  params['compute_attribute']['vm_attrs']['volumes_attributes'] || {}
        params['id'] = params['compute_attribute']['id']
        params['compute_attribute']['vm_attrs']['volumes_attributes'] = volume_attr.merge({new_element_id => option_set_values})
        params
      end

      success_message _('Volume was created.')
      failure_message _('Could not create volume')
      build_options :without => :id
    end

    class UpdateVolume < HammerCLIForeman::UpdateCommand
      command_name 'update-volume'
      desc _('Update compute profile volume.')

      option '--set-values', 'VOLUME', _('Volume parameters, should be comma separated list of values'),
             :required => true,
             :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--volume-id', 'VOLUME_ID', _('Volume id'),
             :required => true,
             :format => HammerCLI::Options::Normalizers::Number.new

      extend_help do |h|
        ::HammerCLIForeman::ComputeResources.extend_help(h, :all)
      end


      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::Attribute.get_params(options)
        volume_attr =  params['compute_attribute']['vm_attrs']['volumes_attributes'] || {}
        params['id'] = params['compute_attribute']['id']
        params['compute_attribute']['vm_attrs']['volumes_attributes'] = volume_attr.merge({option_volume_id => option_set_values})
        params
      end
      success_message _('Volume was updated.')
      failure_message _('Could not update volume')
      build_options :without => :id
    end

    # Using the Update command because removing a volume is done by modifying existing compute_attribute
    class RemoveVolume < HammerCLIForeman::UpdateCommand
      command_name 'remove-volume'
      resource :compute_attributes
      desc _('Remove compute profile volume.')
      option '--volume-id', 'VOLUME_ID', _('Volume id'),
             :format => HammerCLI::Options::Normalizers::Number.new, :required=> true

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::Attribute.get_params(options)
        params['id'] = params['compute_attribute']['id']
        if params['compute_attribute']['vm_attrs']['volumes_attributes'].has_key?(option_volume_id.to_s)
          params['compute_attribute']['vm_attrs']['volumes_attributes'].delete(option_volume_id.to_s)
        else
          signal_usage_error _('unknown volume id')
        end
        params
      end
      success_message _('Volume was removed.')
      failure_message _('Could not remove volume')
      build_options :without => :id
    end

    autoload_subcommands
  end
end
