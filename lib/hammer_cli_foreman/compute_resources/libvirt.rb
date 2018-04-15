require 'hammer_cli_foreman/compute_profile'
require 'hammer_cli_foreman/host'
require 'hammer_cli_foreman/compute_resources/libvirt/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module Libvirt
      HammerCLIForeman::ComputeProfile.add_compute_resource(HammerCLIForeman::ComputeResources::Libvirt::ComputeResourceHelpExtenstion.new)
      HammerCLIForeman::Host.extend_cr_help(ComputeResourceHelpExtenstion.new)
    end
  end
end
