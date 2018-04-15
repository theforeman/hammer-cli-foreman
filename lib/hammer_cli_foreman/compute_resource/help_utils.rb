module HammerCLIForeman
  module ComputeResources
    def self.extend_help(h, attributes)
      h.section _('Provider specific options') do |h|
        ::HammerCLIForeman.compute_resources.each do |name, provider|
          h.section name do |h|
            if attributes == :all || attributes == :volume
              h.section '--volume' do |h|
                h.list(provider.volume_attributes) if defined?(provider.volume_attributes)
              end
            end
            if  attributes == :all || attributes == :interface
              h.section '--interface' do |h|
                h.list(provider.interface_attributes) if defined?(provider.interface_attributes)
              end
            end
            if  attributes == :all || attributes == :compute
              h.section '--compute-attributes' do |h|
                h.list(provider.compute_attributes) if defined?(provider.compute_attributes)
              end
            end
          end
        end
      end
    end
  end
end