require 'hammer_cli_foreman/compute_resources/openstack/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module OpenStack
      HammerCLIForeman::Host.extend_cr_help(HostHelpExtenstion.new)
    end
  end
end
