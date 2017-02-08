require 'hammer_cli_foreman/compute_resources/libvirt/host_help_extenstion'
require 'hammer_cli_foreman/compute_resources/libvirt/compute_attributes'

module HammerCLIForeman
  module ComputeResources
    module Libvirt
      HammerCLIForeman::Host.extend_cr_help(HostHelpExtenstion.new)
    end
  end
end
