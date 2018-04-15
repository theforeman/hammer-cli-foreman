require 'hammer_cli_foreman/compute_profile'
require 'hammer_cli_foreman/host'
require 'hammer_cli_foreman/compute_resources/ovirt/host_help_extenstion'
module HammerCLIForeman
  module ComputeResources
    module Ovirt
      HammerCLIForeman::ComputeProfile.add_compute_resource(HammerCLIForeman::ComputeResources::Ovirt::ComputeResourceHelpExtenstion.new)
      HammerCLIForeman::Host.extend_cr_help(ComputeResourceHelpExtenstion.new)
    end
  end
end
