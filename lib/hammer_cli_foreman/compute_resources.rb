require '../hammer-cli-foreman/lib/hammer_cli_foreman/compute_resource/base'
Dir['../hammer-cli-foreman/lib/hammer_cli_foreman/compute_resource/*'].each {|file| require file }

module HammerCLIForeman
  @compute_resources = {
      'ec2' => HammerCLIForeman::ComputeResources::EC2.new,
      'gce' => HammerCLIForeman::ComputeResources::GCE.new,
      'libvirt' => HammerCLIForeman::ComputeResources::Libvirt.new,
      'openstack' => HammerCLIForeman::ComputeResources::OpenStack.new,
      'ovirt' => HammerCLIForeman::ComputeResources::Ovirt.new,
      'rackspace' => HammerCLIForeman::ComputeResources::Rackspace.new,
      'vmare' => HammerCLIForeman::ComputeResources::VMware.new,
  }
  def self.compute_resources
    @compute_resources
  end
end