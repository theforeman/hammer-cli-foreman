require 'hammer_cli_foreman/compute_resources/rackspace/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module Rackspace
      HammerCLIForeman::Host.extend_cr_help(HostHelpExtenstion.new)
    end
  end
end
