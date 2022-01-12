module HammerCLIForeman
  module CommandExtensions
    class Domain < HammerCLI::CommandExtensions
      option_sources do |sources, command|
        sources.find_by_name('IdResolution').insert_relative(
          :after,
          'IdParams',
          HammerCLIForeman::OptionSources::ReferencedResourceIdParams.new(command)
        )
        sources
      end

      option_family associate: 'dns' do
        child '--dns', 'DNS_NAME', _('Name of DNS proxy to use within this domain'),
              attribute_name: :option_dns_name,
              referenced_resource: :smart_proxy
      end
    end
  end
end
