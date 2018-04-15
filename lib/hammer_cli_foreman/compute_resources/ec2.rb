require 'hammer_cli_foreman/compute_profile'
require 'hammer_cli_foreman/host'
require 'hammer_cli_foreman/compute_resources/ec2/host_help_extenstion'

module HammerCLIForeman
  module ComputeResources
    module EC2
      HammerCLIForeman::ComputeProfile.add_compute_resource(HammerCLIForeman::ComputeResources::EC2::ComputeResourceHelpExtenstion.new)
      HammerCLIForeman::Host.extend_cr_help(ComputeResourceHelpExtenstion.new)
    end
  end
end
