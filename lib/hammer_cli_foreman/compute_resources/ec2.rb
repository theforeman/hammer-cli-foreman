require 'hammer_cli_foreman/compute_resources/ec2/host_help_extenstion'
require 'hammer_cli_foreman/compute_resources/ec2/compute_attributes'

module HammerCLIForeman
  module ComputeResources
    module EC2
      HammerCLIForeman::Host.extend_cr_help(HostHelpExtenstion.new)
    end
  end
end
