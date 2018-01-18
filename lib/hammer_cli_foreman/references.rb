module HammerCLIForeman

  module References


    def self.timestamps(dsl)
      dsl.build do
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end
    end

    def self.taxonomies(dsl)
      dsl.build do
        collection :locations, _("Locations"), :numbered => false, :hide_blank => true do
          custom_field Fields::Reference, :name_key => :title
        end
        collection :organizations, _("Organizations"), :numbered => false, :hide_blank => true do
          custom_field Fields::Reference, :name_key => :title
        end
      end
    end

    def self.users(dsl)
      dsl.build do
        collection :users, _("Users"), :numbered => false do
          custom_field Fields::Reference, :name_key => :login
        end
      end
    end

    def self.usergroups(dsl)
      dsl.build do
        collection :usergroups, _("User groups"), :numbered => true do
          field :name, _("Usergroup")
          field :id, _("Id"), Fields::Id
          collection :roles, _("Roles"), :numbered => false do
            custom_field Fields::Reference
          end
        end
        collection :cached_usergroups, _("Inherited User groups"), :numbered => true do
          field :name, _("Usergroup")
          field :id, _("Id"), Fields::Id
          collection :roles, _("Roles"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end

    def self.smart_proxies(dsl)
      dsl.build do
        collection :smart_proxies, _("Smart proxies"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.compute_resources(dsl)
      dsl.build do
        collection :compute_resources, _("Compute resources"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.media(dsl)
      dsl.build do
        collection :media, _("Installation media"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.config_templates(dsl)
      dsl.build do
        collection :config_templates, _("Templates"), :numbered => false do
          custom_field Fields::Template
        end
      end
    end

    def self.domains(dsl)
      dsl.build do
        collection :domains, _("Domains"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.environments(dsl)
      dsl.build do
        collection :environments, _("Environments"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.hostgroups(dsl)
      dsl.build do
        collection :hostgroups, _("Hostgroups"), :numbered => false do
          custom_field Fields::Reference, :name_key => :title
        end
      end
    end

    def self.subnets(dsl)
      dsl.build do
        collection :subnets, _("Subnets"), :numbered => false do
          custom_field Fields::Reference, :details => :network_address
        end
      end
    end

    def self.parameters(dsl)
      dsl.build do
        collection :parameters, _("Parameters"), :numbered => false do
          custom_field Fields::KeyValue
        end
      end
    end

    def self.all_parameters(dsl)
      dsl.build do
        collection :all_parameters, _("All parameters"), :numbered => false do
          custom_field Fields::KeyValue
        end
      end
    end

    def self.puppetclasses(dsl)
      dsl.build do
        collection :puppetclasses, _("Puppetclasses"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.operating_systems(dsl)
      dsl.build do
        collection :operatingsystems, _("Operating systems"), :numbered => false do
          custom_field Fields::Reference, :name_key => :title
        end
      end
    end

    def self.roles(dsl)
      dsl.build do
        collection :roles, _("Roles"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.external_usergroups(dsl)
      dsl.build do
        collection :external_usergroups, _("External user groups"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

  end
end
