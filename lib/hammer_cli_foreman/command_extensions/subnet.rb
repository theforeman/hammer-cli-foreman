module HammerCLIForeman
  module CommandExtensions
    class Subnet < HammerCLI::CommandExtensions
      option "--dns", "DNS_NAME", _("DNS Proxy to use within this subnet"),
             attribute_name: :option_dns_name,
             referenced_resource: :smart_proxy
      option "--dhcp", "DHCP_NAME", _("DHCP Proxy to use within this subnet"),
             attribute_name: :option_dhcp_name,
             referenced_resource: :smart_proxy
      option "--tftp", "TFTP_NAME", _("TFTP Proxy to use within this subnet"),
             attribute_name: :option_tftp_name,
             referenced_resource: :smart_proxy
      option "--prefix", "PREFIX", _("Network prefix in CIDR notation (e.g. 64) for this subnet")

      option_sources do |sources, command|
        sources.find_by_name('IdResolution').insert_relative(
          :after,
          'IdParams',
          HammerCLIForeman::OptionSources::ReferencedResourceIdParams.new(command)
        )
        sources
      end
    end
  end
end
