require 'hammer_cli_foreman/compute_resources/ovirt/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module Ovirt
      HammerCLIForeman::Host.extend_cr_help(HostHelpExtenstion.new)
    end
  end
end
