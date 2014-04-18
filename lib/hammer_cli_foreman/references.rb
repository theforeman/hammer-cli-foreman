module HammerCLIForeman

  module References

    module Timestamps

      def self.included(base)
        base.output do
          field :created_at, _("Created at"), Fields::Date
          field :updated_at, _("Updated at"), Fields::Date
        end
      end
    end

    module Taxonomies

      def self.included(base)
        base.output do
          collection :locations, _("Locations"), :numbered => false, :hide_blank => true do
            custom_field Fields::Reference
          end
          collection :organizations, _("Organizations"), :numbered => false, :hide_blank => true do
            custom_field Fields::Reference
          end
        end
      end
    end


    module Users

      def self.included(base)
        base.output do
          collection :users, _("Users"), :numbered => false do
            custom_field Fields::Reference, :name_key => :login
          end
        end
      end
    end


    module SmartProxies

      def self.included(base)
        base.output do
          collection :smart_proxies, _("Smart proxies"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end


    module ComputeResources

      def self.included(base)
        base.output do
          collection :compute_resources, _("Compute resources"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end


    module Media

      def self.included(base)
        base.output do
          collection :media, _("Installation media"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end

    module ConfigTemplates

      def self.included(base)
        base.output do
          collection :config_templates, _("Templates"), :numbered => false do
            custom_field Fields::Template
          end
        end
      end
    end


    module Domains

      def self.included(base)
        base.output do
          collection :domains, _("Domains"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end


    module Environments

      def self.included(base)
        base.output do
          collection :environments, _("Environments"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end


    module Hostgroups

      def self.included(base)
        base.output do
          collection :hostgroups, _("Hostgroups"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end


    module Subnets

      def self.included(base)
        base.output do
          collection :subnets, _("Subnets"), :numbered => false do
            custom_field Fields::Reference, :details => :network_address
          end
        end
      end
    end



    module Parameters

      def self.included(base)
        base.output do
          collection :parameters, _("Parameters"), :numbered => false do
            custom_field Fields::KeyValue
          end
        end
      end
    end

    module Puppetclasses

      def self.included(base)
        base.output do
          collection :puppetclasses, _("Puppetclasses"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end


    module OperatingSystems

      def self.included(base)
        base.output do
          collection :operatingsystems, _("Operating systems"), :numbered => false do
            custom_field Fields::Reference, :name_key => :fullname
          end
        end
      end
    end

  end
end
