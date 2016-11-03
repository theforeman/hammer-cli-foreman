require 'hammer_cli_foreman/compute_resources/gce/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module GCE
      HammerCLIForeman::Host.extend_cr_help(HostHelpExtenstion.new)
    end
  end
end
