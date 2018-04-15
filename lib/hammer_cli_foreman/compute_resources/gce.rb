require 'hammer_cli_foreman/compute_profile'
require 'hammer_cli_foreman/host'
require 'hammer_cli_foreman/compute_resources/gce/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module GCE
      HammerCLIForeman::ComputeProfile.add_compute_resource(HammerCLIForeman::ComputeResources::GCE::ComputeResourceHelpExtenstion.new)
      HammerCLIForeman::Host.extend_cr_help(ComputeResourceHelpExtenstion.new)
    end
  end
end
