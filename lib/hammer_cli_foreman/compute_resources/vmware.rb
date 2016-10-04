require 'hammer_cli_foreman/compute_resources/vmware/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module VMware
      HammerCLIForeman::Host.extend_cr_help(HostHelpExtenstion.new)
    end
  end
end
