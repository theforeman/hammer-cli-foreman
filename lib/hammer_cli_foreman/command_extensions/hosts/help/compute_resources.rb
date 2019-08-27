module HammerCLIForeman
  module CommandExtensions
    module Hosts
      module Help
        class ComputeResources < HammerCLI::CommandExtensions
          class << self
            attr_writer :current_providers, :add_host_specific_attrs,
                        :attributes

            def current_providers
              @current_providers ||= HammerCLIForeman.compute_resources.keys
              @current_providers
            end

            def add_host_specific_attrs?
              @add_host_specific_attrs ||= false
              @add_host_specific_attrs
            end

            def attributes
              @attributes ||= :all
              @attributes
            end

            def customized?
              @customized
            end

            def customized=(boolean)
              @customized ||= boolean
            end

            def custom(options = {})
              new_self = Class.new(ComputeResources)
              new_self.add_host_specific_attrs = options[:add_host_specific_attrs]
              new_self.attributes = options[:attributes]
              new_self.current_providers = options[:providers]
              new_self.class_eval(&help_block)
              new_self.customized = true
              new_self
            end

            def help_block
              @help_block ||= Proc.new do
                help do |h|
                  h.section(_('Provider specific options')) do |h|
                    h.note(_('Bold attributes are required.'), richtext: true)
                    HammerCLIForeman.compute_resources.each do |name, provider|
                      next unless current_providers.include?(name)

                      h.section(provider.name, id: name.to_sym) do |h|
                        compute_attributes = provider.compute_attributes
                        compute_attributes += provider.host_attributes if add_host_specific_attrs?
                        if %i[all volume].include?(attributes)
                          h.section('--volume') do |h|
                            h.list(provider.volume_attributes)
                          end
                        end
                        if %i[all interface].include?(attributes)
                          h.section('--interface') do |h|
                            h.list(provider.interface_attributes)
                          end
                        end
                        if %i[all compute].include?(attributes)
                          h.section('--compute-attributes', id: :s_compute_attributes) do |h|
                            h.list(compute_attributes, id: :l_compute_attributes)
                          end
                        end
                      end
                      provider.extend_help(h) if provider.respond_to?(:extend_help)
                    end
                  end
                end
              end
            end
          end

          def initialize(options = {})
            super
            self.class.class_eval(&self.class.help_block) unless self.class.customized?
          end
        end
      end
    end
  end
end
