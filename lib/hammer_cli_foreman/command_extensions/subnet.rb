module HammerCLIForeman
  module CommandExtensions
    class Subnet < HammerCLI::CommandExtensions
      option '--prefix', 'PREFIX', _('Network prefix in CIDR notation (e.g. 64) for this subnet')

      option_sources do |sources, command|
        sources.find_by_name('IdResolution').insert_relative(
          :after,
          'IdParams',
          HammerCLIForeman::OptionSources::ReferencedResourceIdParams.new(command)
        )
        sources
      end

      option_family associate: 'tftp' do
        child '--tftp', 'TFTP_NAME', _('TFTP Proxy to use within this subnet'),
              attribute_name: :option_tftp_name,
              referenced_resource: :smart_proxy
      end

      option_family associate: 'dns' do
        child '--dns', 'DNS_NAME', _('DNS Proxy to use within this subnet'),
              attribute_name: :option_dns_name,
              referenced_resource: :smart_proxy
      end

      option_family associate: 'dhcp' do
        child '--dhcp', 'DHCP_NAME', _('DHCP Proxy to use within this subnet'),
              attribute_name: :option_dhcp_name,
              referenced_resource: :smart_proxy
      end

      option_family associate: 'bmc' do
        child '--bmc', 'BMC_NAME', _('BMC Proxy to use within this subnet'),
              attribute_name: :option_bmc_name,
              referenced_resource: :smart_proxy
      end
    end
  end
end
