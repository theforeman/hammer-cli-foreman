require 'hammer_cli_foreman/image'
require 'hammer_cli_foreman/compute_resource/register_compute_resources'

module HammerCLIForeman
  class ComputeAttribute < HammerCLIForeman::Command
    resource :compute_attributes

    def self.get_params(options)
      params = {}
      params['compute_attribute'] = {}
      profile = HammerCLIForeman.record_to_common_format(
          HammerCLIForeman.foreman_resource(:compute_profiles).call(:show, 'id' => options['option_compute_profile_id'] )
      )
      params['compute_attribute'] = profile['compute_attributes'].select { |hash| hash['compute_resource_id'] == options['option_compute_resource_id']}[0] || {}
      params['compute_attribute'].delete('attributes') if params['compute_attribute']['attributes']
      params
    end

    def self.attribute_hash(attribute_list)
      attribute_list.size.times.map { |idx| idx.to_s }.zip(attribute_list).to_h
    end

    class Create < HammerCLIForeman::CreateCommand
      desc _('Create compute profile set of values')

      option '--compute-attributes', 'COMPUTE_ATTRS', _('Compute resource attributes'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--interface', 'INTERFACE', _('Interface parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :multivalued => true
      option '--volume', 'VOLUME', _('Volume parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :multivalued => true

      validate_options do
        any(:option_compute_profile_id, :option_compute_profile_name ).required
        any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = super
        compute_resource_name = HammerCLIForeman.record_to_common_format(HammerCLIForeman.foreman_resource(:compute_resources).call(:show, 'id' => options["option_compute_resource_id"] ))["provider_friendly_name"].downcase
        interfaces_attr_name = ::HammerCLIForeman.compute_resources[compute_resource_name].interfaces_attrs_name
        params['compute_attribute']['vm_attrs'] = option_compute_attributes || {}
        params['compute_attribute']['vm_attrs'][interfaces_attr_name]= HammerCLIForeman::ComputeAttribute.attribute_hash(option_interface_list) unless option_interface_list.empty?
        params['compute_attribute']['vm_attrs']['volumes_attributes'] = HammerCLIForeman::ComputeAttribute.attribute_hash(option_volume_list) unless option_volume_list.empty?
        params
      end

      success_message _('Compute profile attributes are set.')
      failure_message _('Could not set the compute profile attributes')
      build_options

      extend_with(HammerCLIForeman::CommandExtensions::Hosts::Help::ComputeResources.new)
    end

    class Update < HammerCLIForeman::UpdateCommand
      desc _('Update compute profile values')

      option '--compute-attributes', 'COMPUTE_ATTRS', _('Compute resource attributes, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--interface', 'INTERFACE', _('Interface parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :multivalued => true
      option '--volume', 'VOLUME', _('Volume parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :multivalued => true

      validate_options do
        any(:option_compute_profile_id, :option_compute_profile_name ).required
        any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params

        params = HammerCLIForeman::ComputeAttribute.get_params(options)
        compute_resource_name = HammerCLIForeman.record_to_common_format(HammerCLIForeman.foreman_resource(:compute_resources).call(:show, 'id' => options["option_compute_resource_id"] ))["provider_friendly_name"].downcase
        interfaces_attr_name = ::HammerCLIForeman.compute_resources[compute_resource_name].interfaces_attrs_name

        raise ArgumentError, "Compute profile value to update does not exist yet; it needs to be created first" if !params['compute_attribute'].key?('id')
        params['id'] =  params['compute_attribute']['id']
        vm_attrs = params['compute_attribute']['vm_attrs']
        original_volumes = vm_attrs['volumes_attributes'] || {}
        original_interfaces = vm_attrs[interfaces_attr_name] || {}

        if options['option_compute_attributes']
          vm_attrs = options['option_compute_attributes']
          vm_attrs['volumes_attributes'] ||= original_volumes
          vm_attrs[interfaces_attr_name] ||= original_interfaces
        end
        vm_attrs[interfaces_attr_name] = HammerCLIForeman::ComputeAttribute.attribute_hash(options['option_interface_list']) unless options['option_interface_list'].empty?
        vm_attrs['volumes_attributes'] = HammerCLIForeman::ComputeAttribute.attribute_hash(options['option_volume_list']) unless options['option_volume_list'].empty?
        params['compute_attribute']['vm_attrs'] = vm_attrs
        params

      end
      success_message _('Compute profile attributes updated.')
      failure_message _('Could not update the compute profile attributes')

      build_options :without => :id

      extend_with(HammerCLIForeman::CommandExtensions::Hosts::Help::ComputeResources.new)
    end

    # Using the Update command because adding a new interface is done by modifying existing compute_attribute
    class AddInterface < HammerCLIForeman::UpdateCommand
      command_name 'add-interface'
      desc _('Add interface for Compute Profile')
      option '--interface', 'SET_VALUES', _('Interface parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :required => true

      def validate_options
        super
        validator.any(:option_compute_profile_id,:option_compute_profile_name).required
        validator.any(:option_compute_resource_id,:option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::ComputeAttribute.get_params(options)

        raise ArgumentError, "Compute profile value to update does not exist yet; it needs to be created first" if !params['compute_attribute'].key?('id')
        compute_resource_name = HammerCLIForeman.record_to_common_format(HammerCLIForeman.foreman_resource(:compute_resources).call(:show, 'id' => options["option_compute_resource_id"] ))["provider_friendly_name"].downcase


        interfaces_attr_name = ::HammerCLIForeman.compute_resources[compute_resource_name].interfaces_attrs_name
        interface_attr =  params['compute_attribute']['vm_attrs'][interfaces_attr_name] || {}
        new_interface_id = (interface_attr.keys.max.to_i + 1 ).to_s if interface_attr.any?
        new_interface_id ||= "0"
        params['id'] = params['compute_attribute']['id']

        params['compute_attribute']['vm_attrs'][interfaces_attr_name] ||= {}
        params['compute_attribute']['vm_attrs'][interfaces_attr_name][new_interface_id] = option_interface
        params
      end

      success_message _('Interface was created.')
      failure_message _('Could not create interface')

      build_options :without => :id

      extend_with(HammerCLIForeman::CommandExtensions::Hosts::Help::ComputeResources.custom(attributes: :interface).new)
    end

    class UpdateInterface < HammerCLIForeman::UpdateCommand
      command_name 'update-interface'

      desc _('Update compute profile interface')

      option '--interface', 'SET_VALUES', _('Interface parameters, should be comma separated list of values'),
             :required => true,
             :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--interface-id', 'INTERFACE_ID', _('Interface id'),
             :required => true,
             :format => HammerCLI::Options::Normalizers::Number.new

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::ComputeAttribute.get_params(options)
        raise ArgumentError, "Compute profile value to update does not exist yet; it needs to be created first" if !params['compute_attribute'].key?('id')
        compute_resource_name = HammerCLIForeman.record_to_common_format(HammerCLIForeman.foreman_resource(:compute_resources).call(:show, 'id' => options["option_compute_resource_id"] ))["provider_friendly_name"].downcase
        interfaces_attr_name = ::HammerCLIForeman.compute_resources[compute_resource_name].interfaces_attrs_name
        params['id'] = params['compute_attribute']['id']
        params['compute_attribute']['vm_attrs'][interfaces_attr_name] ||= {}
        params['compute_attribute']['vm_attrs'][interfaces_attr_name][option_interface_id] = option_interface
        params
      end
      success_message _('Interface was updated.')
      failure_message _('Could not update interface')
      build_options :without => :id

      extend_with(HammerCLIForeman::CommandExtensions::Hosts::Help::ComputeResources.custom(attributes: :interface).new)
    end

    # Using the Update command because removing an interface is done by modifying existing compute_attribute
    class RemoveInterface < HammerCLIForeman::UpdateCommand
      command_name 'remove-interface'
      desc _('Remove compute profile interface')
      option '--interface-id', 'INTERFACE ID', _('Interface id'),
             :format => HammerCLI::Options::Normalizers::Number.new , :required => true

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::ComputeAttribute.get_params(options)
        raise ArgumentError, "Compute profile value to update does not exist yet; it needs to be created first" if !params['compute_attribute'].key?('id')
        compute_resource_name = HammerCLIForeman.record_to_common_format(HammerCLIForeman.foreman_resource(:compute_resources).call(:show, 'id' => options["option_compute_resource_id"] ))["provider_friendly_name"].downcase
        interfaces_attr_name = ::HammerCLIForeman.compute_resources[compute_resource_name].interfaces_attrs_name
        params['id'] = params['compute_attribute']['id']
        if params['compute_attribute']['vm_attrs'][interfaces_attr_name].has_key?(option_interface_id.to_s)
          params['compute_attribute']['vm_attrs'][interfaces_attr_name].delete(option_interface_id.to_s)
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
      desc _('Add volume for Compute Profile')

      option '--volume', 'VOLUME', _('Volume parameters, should be comma separated list of values'),
             :format => HammerCLI::Options::Normalizers::KeyValueList.new, :required => true

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::ComputeAttribute.get_params(options)
        raise ArgumentError, "Compute profile value to update does not exist yet; it needs to be created first" if !params['compute_attribute'].key?('id')
        volume_attr =  params['compute_attribute']['vm_attrs']['volumes_attributes'] || {}
        new_volume_id = (volume_attr.keys.max.to_i + 1 ).to_s if volume_attr.any?
        new_volume_id ||= "0"
        params['id'] = params['compute_attribute']['id']
        params['compute_attribute']['vm_attrs']['volumes_attributes'] ||= {}
        params['compute_attribute']['vm_attrs']['volumes_attributes'][new_volume_id] = option_volume
        params
      end

      success_message _('Volume was created.')
      failure_message _('Could not create volume')
      build_options :without => :id

      extend_with(HammerCLIForeman::CommandExtensions::Hosts::Help::ComputeResources.custom(attributes: :volume).new)
    end

    class UpdateVolume < HammerCLIForeman::UpdateCommand
      command_name 'update-volume'
      desc _('Update compute profile volume')

      option '--volume', 'VOLUME', _('Volume parameters, should be comma separated list of values'),
             :required => true,
             :format => HammerCLI::Options::Normalizers::KeyValueList.new
      option '--volume-id', 'VOLUME_ID', _('Volume id'),
             :required => true,
             :format => HammerCLI::Options::Normalizers::Number.new

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::ComputeAttribute.get_params(options)
        raise ArgumentError, "Compute profile value to update does not exist yet; it needs to be created first" if !params['compute_attribute'].key?('id')
        params['id'] = params['compute_attribute']['id']
        params['compute_attribute']['vm_attrs']['volumes_attributes'] ||= {}
        params['compute_attribute']['vm_attrs']['volumes_attributes'][option_volume_id] = option_volume
        params
      end
      success_message _('Volume was updated.')
      failure_message _('Could not update volume')
      build_options :without => :id

      extend_with(HammerCLIForeman::CommandExtensions::Hosts::Help::ComputeResources.custom(attributes: :volume).new)
    end

    # Using the Update command because removing a volume is done by modifying existing compute_attribute
    class RemoveVolume < HammerCLIForeman::UpdateCommand
      command_name 'remove-volume'
      resource :compute_attributes
      desc _('Remove compute profile volume')
      option '--volume-id', 'VOLUME_ID', _('Volume id'),
             :format => HammerCLI::Options::Normalizers::Number.new, :required=> true

      def validate_options
        super
        validator.any(:option_compute_profile_id, :option_compute_profile_name).required
        validator.any(:option_compute_resource_id, :option_compute_resource_name).required
      end

      def request_params
        params = HammerCLIForeman::ComputeAttribute.get_params(options)
        raise ArgumentError, "Compute profile value to update does not exist yet; it needs to be created first" if !params['compute_attribute'].key?('id')
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
