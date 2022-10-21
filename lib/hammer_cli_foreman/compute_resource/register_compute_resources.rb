module HammerCLIForeman
  @compute_resources = {}
  def self.compute_resources
    @compute_resources
  end

  def self.register_compute_resource(name, compute_resource)
    @compute_resources[name] = compute_resource
  end

  require 'hammer_cli_foreman/compute_resource/base'
  require 'hammer_cli_foreman/compute_resource/ec2.rb'
  require 'hammer_cli_foreman/compute_resource/libvirt.rb'
  require 'hammer_cli_foreman/compute_resource/openstack.rb'
  require 'hammer_cli_foreman/compute_resource/ovirt.rb'
  require 'hammer_cli_foreman/compute_resource/rackspace.rb'
  require 'hammer_cli_foreman/compute_resource/vmware.rb'
end
