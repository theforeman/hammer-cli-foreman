require 'hammer_cli_foreman/compute_profile'
require 'hammer_cli_foreman/host'
require 'hammer_cli_foreman/compute_resources/rackspace/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module Rackspace
      HammerCLIForeman::ComputeProfile.add_compute_resource(HammerCLIForeman::ComputeResources::Rackspace::ComputeResourceHelpExtenstion.new)
      HammerCLIForeman::Host.extend_cr_help(ComputeResourceHelpExtenstion.new)
    end
  end
end
